// 1. Reemplazamos las librerías de DynamoDB por las de Amazon SQS
const { SQSClient, SendMessageCommand } = require("@aws-sdk/client-sqs");
const { randomUUID: uuidv4 } = require("crypto");


// Inicializamos el cliente SQS fuera del handler para optimizar el rendimiento
const sqsClient = new SQSClient({});
const QUEUE_URL = process.env.QUEUE_URL;

const corsHeaders = {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Headers": "Content-Type,X-Amz-Date,Authorization,X-Api-Key",
    "Access-Control-Allow-Methods": "GET,POST,PUT,DELETE,OPTIONS"
};

const buildResponse = (statusCode, body) => ({
    statusCode,
    headers: corsHeaders,
    body: JSON.stringify(body)
});

exports.handler = async (event) => {
    if (event.httpMethod === "OPTIONS") {
        return {
            statusCode: 200,
            headers: corsHeaders,
            body: ""
        };
    }

    try {
        const body = JSON.parse(event.body || "{}");
        
        // Extracción del usuario autenticado vía Cognito authorizer
        const claims = event.requestContext?.authorizer?.claims || {};
        const ownerId = claims.sub || "anonymous-user";

        // Validación 1: No permitir fileName vacío o ausente
        if (!body.fileName || body.fileName.trim() === "") {
            return buildResponse(400, { message: "Bad Request: fileName cannot be empty" });
        }

        // Validación 2: No permitir size negativo
        if (typeof body.size !== "number" || body.size < 0) {
            return buildResponse(400, { message: "Bad Request: size must be a positive number" });
        }

        // Validación 3: No permitir category vacía o ausente
        if (!body.category || body.category.trim() === "") {
            return buildResponse(400, { message: "Bad Request: category cannot be empty" });
        }

        // Construcción del objeto del documento
        const file = {
            fileId: uuidv4(),
            ownerId: ownerId,
            fileName: body.fileName,
            category: body.category,
            size: body.size,
            status: "QUEUED",
            uploadDate: new Date().toISOString()
        };

        // 2. Preparamos el comando para enviar el objeto como mensaje a SQS
        const command = new SendMessageCommand({
            QueueUrl: QUEUE_URL,
            MessageBody: JSON.stringify(file),
            MessageAttributes: {
                Category: {
                    DataType: "String",
                    StringValue: String(file.category)
                },
                OwnerId: {
                    DataType: "String",
                    StringValue: String(file.ownerId)
                }
            }
        });

        // 3. Enviamos el mensaje de forma asíncrona a Amazon SQS
        const response = await sqsClient.send(command);

        console.log(`Documento encolado en SQS exitosamente. MessageId: ${response.MessageId}`);

        // Retornamos 200/202 confirmando al frontend que el procesamiento inició
        return buildResponse(200, {
            message: "Message queued",
            sqsMessageId: response.MessageId
        });

    } catch (error) {
        console.error("Error crítico en Lambda Productora:", error);
        return buildResponse(500, {
            message: "Internal Server Error",
            error: error.message
        });
    }
};