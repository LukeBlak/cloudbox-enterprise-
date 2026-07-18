const { DynamoDBClient } = require("@aws-sdk/client-dynamodb");
const { DynamoDBDocumentClient, PutCommand } = require("@aws-sdk/lib-dynamodb");

const client = new DynamoDBClient({});
const docClient = DynamoDBDocumentClient.from(client);
const TABLE_NAME = process.env.TABLE_NAME;

exports.handler = async (event) => {
    console.log("Mensajes recibidos desde SQS:", JSON.stringify(event));

    try {
        for (const record of event.Records) {
            const body = JSON.parse(record.body);
            console.log("Procesando y guardando ítem en DynamoDB:", body);

            const command = new PutCommand({
                TableName: TABLE_NAME,
                Item: body
            });

            await docClient.send(command);
        }
        return { statusCode: 200, body: "Procesado exitosamente" };
    } catch (error) {
        console.error("Error procesando mensajes de SQS:", error);
        throw error; 
    }
};