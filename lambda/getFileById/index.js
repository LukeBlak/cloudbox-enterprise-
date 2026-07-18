const { DynamoDBClient } =
require("@aws-sdk/client-dynamodb");
const {
   DynamoDBDocumentClient,
   GetCommand
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
   const fileId =
   event.pathParameters.id;
   const result =
   await docClient.send(
       new GetCommand({
           TableName: "Files",
           Key: {
               fileId
           }
       })
   );
   if (
       !result.Item ||
       result.Item.ownerId !== ownerId
   ) {
       return buildResponse(403, {
           message: "Forbidden"
       });
   }
   return buildResponse(200, result.Item);
};
