const { DynamoDBClient } = require("@aws-sdk/client-dynamodb");
const { DynamoDBDocumentClient, UpdateCommand } = require("@aws-sdk/lib-dynamodb");

const client = new DynamoDBClient({});
const docClient = DynamoDBDocumentClient.from(client);

const corsHeaders = {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Headers": "Content-Type,Authorization,x-api-key",
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
    const claims = event.requestContext.authorizer.claims;
    const ownerId = claims.sub;
    const fileId = event.pathParameters.id;
    
    // Obtenemos los nuevos valores desde el cuerpo de la petición (body)
    const { fileName, category, size } = JSON.parse(event.body || "{}");

    try {
        const result = await docClient.send(
            new UpdateCommand({
                TableName: "Files",
                Key: { fileId },
                // Condición: El item debe existir Y el ownerId debe coincidir
                ConditionExpression: "attribute_exists(fileId) AND ownerId = :ownerId",
                // Expresión para actualizar únicamente los 3 campos solicitados
                UpdateExpression: "SET fileName = :fileName, category = :category, #sizeAttr = :size",
                // 'size' es una palabra reservada en DynamoDB, por lo que usamos un alias (#sizeAttr)
                ExpressionAttributeNames: {
                    "#sizeAttr": "size"
                },
                ExpressionAttributeValues: {
                    ":ownerId": ownerId,
                    ":fileName": fileName,
                    ":category": category,
                    ":size": size
                },
                // Indica que devuelva el item modificado con los nuevos valores
                ReturnValues: "ALL_NEW"
            })
        );

        return buildResponse(200, {
            message: "Archivo actualizado con éxito",
            item: result.Attributes
        });

    } catch (error) {
        // Si la condición falla (el archivo no existe o el ownerId no coincide)
        if (error.name === "ConditionalCheckFailedException") {
            return buildResponse(403, {
                message: "Forbidden o el archivo no existe"
            });
        }

        // Manejo de otros errores internos
        return buildResponse(500, {
            message: "Internal Server Error",
            error: error.message
        });
    }
};