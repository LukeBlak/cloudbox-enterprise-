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

    try {
        const result = await docClient.send(
            new UpdateCommand({
                TableName: "Files",
                Key: { fileId },
                // Condición: El archivo debe existir y el ownerId debe ser igual al del usuario
                ConditionExpression: "attribute_exists(fileId) AND ownerId = :ownerId",
                // Expresión de actualización: Cambiamos el estado a "DELETED"
                // 'status' es una palabra reservada en DynamoDB, por lo que usamos el alias #statusAttr
                UpdateExpression: "SET #statusAttr = :statusValue",
                ExpressionAttributeNames: {
                    "#statusAttr": "status"
                },
                ExpressionAttributeValues: {
                    ":ownerId": ownerId,
                    ":statusValue": "DELETED"
                },
                // Opcional: Devuelve el item modificado para confirmar el cambio
                ReturnValues: "ALL_NEW"
            })
        );

        return buildResponse(200, {
            message: "Archivo eliminado lógicamente con éxito",
            item: result.Attributes
        });

    } catch (error) {
        // Si el ownerId no coincide o el registro no existe, DynamoDB lanza esta excepción
        if (error.name === "ConditionalCheckFailedException") {
            return buildResponse(403, {
                message: "Forbidden o el archivo no existe"
            });
        }

        // Manejo de otros errores del servidor
        return buildResponse(500, {
            message: "Internal Server Error",
            error: error.message
        });
    }
};