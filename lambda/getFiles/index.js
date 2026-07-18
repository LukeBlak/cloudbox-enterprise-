const { DynamoDBClient } =
require("@aws-sdk/client-dynamodb");

const {
   DynamoDBDocumentClient,
   ScanCommand
} = require("@aws-sdk/lib-dynamodb");

const client =
new DynamoDBClient({});

const docClient =
DynamoDBDocumentClient.from(client);

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
   const claims =
   event.requestContext.authorizer.claims;
   const ownerId =
   claims.sub;
   const result =
   await docClient.send(
       new ScanCommand({
           TableName: "Files"
       })
   );
   const files =
   result.Items.filter(

       item =>
       item.ownerId === ownerId &&
       item.status === "ACTIVE"
   );
   return buildResponse(200, files);
};
