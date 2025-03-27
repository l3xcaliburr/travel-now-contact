const AWS = require("aws-sdk");
const dynamoDB = new AWS.DynamoDB.DocumentClient();
const ses = new AWS.SES();
const { v4: uuidv4 } = require("uuid");

// Environment variables
const TABLE_NAME = process.env.DYNAMODB_TABLE_NAME;
const FROM_EMAIL = process.env.FROM_EMAIL_ADDRESS;
const TO_EMAIL = process.env.TO_EMAIL_ADDRESS;

exports.handler = async (event) => {
  try {
    // Log the incoming event for debugging
    console.log("Received event:", JSON.stringify(event));

    // Parse the request body
    const body = JSON.parse(event.body);

    // Validate required fields
    if (!body.name || !body.email) {
      return formatResponse(400, {
        message: "Missing required fields: name and email are required",
      });
    }

    // Generate a unique ID for the submission
    const submissionId = uuidv4();
    const timestamp = new Date().toISOString();

    // Prepare item for DynamoDB
    const item = {
      id: submissionId,
      name: body.name,
      email: body.email,
      phone: body.phone || null,
      destination: body.destination || null,
      travelDateStart: body.travelDateStart || null,
      travelDateEnd: body.travelDateEnd || null,
      travelers: body.travelers || null,
      message: body.message || null,
      submittedAt: timestamp,
    };

    // Save to DynamoDB
    await dynamoDB
      .put({
        TableName: TABLE_NAME,
        Item: item,
      })
      .promise();

    // Send email confirmation to customer
    await sendCustomerConfirmation(item);

    // Send notification to business
    await sendBusinessNotification(item);

    // Return success response
    return formatResponse(200, {
      message: "Form submitted successfully",
      submissionId,
      timestamp,
    });
  } catch (error) {
    console.error("Error processing submission:", error);
    return formatResponse(500, {
      message: "Error processing submission",
      error: error.message,
    });
  }
};

/**
 * Format API Gateway response
 */
function formatResponse(statusCode, body) {
  return {
    statusCode,
    headers: {
      "Content-Type": "application/json",
      "Access-Control-Allow-Origin": "*", // Allow requests from any origin
      "Access-Control-Allow-Methods": "POST, OPTIONS",
      "Access-Control-Allow-Headers":
        "Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token",
    },
    body: JSON.stringify(body),
  };
}

/**
 * Send confirmation email to customer
 */
async function sendCustomerConfirmation(formData) {
  const params = {
    Destination: {
      ToAddresses: [formData.email],
    },
    Message: {
      Body: {
        Html: {
          Charset: "UTF-8",
          Data: `
                        <html>
                            <head>
                                <style>
                                    body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
                                    .container { max-width: 600px; margin: 0 auto; padding: 20px; }
                                    h1 { color: #2c3e50; }
                                    .footer { margin-top: 30px; font-size: 12px; color: #7f8c8d; }
                                </style>
                            </head>
                            <body>
                                <div class="container">
                                    <h1>Thank You for Your Travel Inquiry</h1>
                                    <p>Dear ${formData.name},</p>
                                    <p>We have received your travel inquiry. Here's a summary of the information you provided:</p>
                                    <ul>
                                        ${
                                          formData.destination
                                            ? `<li>Destination: ${formData.destination}</li>`
                                            : ""
                                        }
                                        ${
                                          formData.travelDateStart
                                            ? `<li>Travel Dates: ${
                                                formData.travelDateStart
                                              } to ${
                                                formData.travelDateEnd || "TBD"
                                              }</li>`
                                            : ""
                                        }
                                        ${
                                          formData.travelers
                                            ? `<li>Number of Travelers: ${formData.travelers}</li>`
                                            : ""
                                        }
                                    </ul>
                                    <p>A member of our team will review your inquiry and get back to you shortly.</p>
                                    <p>Your reference number is: <strong>${
                                      formData.id
                                    }</strong></p>
                                    <p>Best regards,<br>The Travel Team</p>
                                    <div class="footer">
                                        <p>This is an automated message. Please do not reply to this email.</p>
                                    </div>
                                </div>
                            </body>
                        </html>
                    `,
        },
        Text: {
          Charset: "UTF-8",
          Data: `
                        Thank You for Your Travel Inquiry
                        
                        Dear ${formData.name},
                        
                        We have received your travel inquiry. Here's a summary of the information you provided:
                        
                        ${
                          formData.destination
                            ? `Destination: ${formData.destination}`
                            : ""
                        }
                        ${
                          formData.travelDateStart
                            ? `Travel Dates: ${formData.travelDateStart} to ${
                                formData.travelDateEnd || "TBD"
                              }`
                            : ""
                        }
                        ${
                          formData.travelers
                            ? `Number of Travelers: ${formData.travelers}`
                            : ""
                        }
                        
                        A member of our team will review your inquiry and get back to you shortly.
                        
                        Your reference number is: ${formData.id}
                        
                        Best regards,
                        The Travel Team
                        
                        This is an automated message. Please do not reply to this email.
                    `,
        },
      },
      Subject: {
        Charset: "UTF-8",
        Data: "Thank You for Your Travel Inquiry",
      },
    },
    Source: FROM_EMAIL,
  };

  return ses.sendEmail(params).promise();
}

/**
 * Send notification to business
 */
async function sendBusinessNotification(formData) {
  const params = {
    Destination: {
      ToAddresses: [TO_EMAIL],
    },
    Message: {
      Body: {
        Html: {
          Charset: "UTF-8",
          Data: `
                        <html>
                            <head>
                                <style>
                                    body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
                                    .container { max-width: 600px; margin: 0 auto; padding: 20px; }
                                    h1 { color: #2c3e50; }
                                    table { border-collapse: collapse; width: 100%; }
                                    table, th, td { border: 1px solid #ddd; }
                                    th, td { padding: 12px; text-align: left; }
                                    th { background-color: #f2f2f2; }
                                </style>
                            </head>
                            <body>
                                <div class="container">
                                    <h1>New Travel Inquiry</h1>
                                    <p>A new travel inquiry has been submitted with the following details:</p>
                                    <table>
                                        <tr>
                                            <th>Reference ID</th>
                                            <td>${formData.id}</td>
                                        </tr>
                                        <tr>
                                            <th>Name</th>
                                            <td>${formData.name}</td>
                                        </tr>
                                        <tr>
                                            <th>Email</th>
                                            <td>${formData.email}</td>
                                        </tr>
                                        ${
                                          formData.phone
                                            ? `<tr><th>Phone</th><td>${formData.phone}</td></tr>`
                                            : ""
                                        }
                                        ${
                                          formData.destination
                                            ? `<tr><th>Destination</th><td>${formData.destination}</td></tr>`
                                            : ""
                                        }
                                        ${
                                          formData.travelDateStart
                                            ? `<tr><th>Travel Dates</th><td>${
                                                formData.travelDateStart
                                              } to ${
                                                formData.travelDateEnd || "TBD"
                                              }</td></tr>`
                                            : ""
                                        }
                                        ${
                                          formData.travelers
                                            ? `<tr><th>Travelers</th><td>${formData.travelers}</td></tr>`
                                            : ""
                                        }
                                        <tr>
                                            <th>Message</th>
                                            <td>${
                                              formData.message ||
                                              "No message provided"
                                            }</td>
                                        </tr>
                                        <tr>
                                            <th>Submitted At</th>
                                            <td>${formData.submittedAt}</td>
                                        </tr>
                                    </table>
                                </div>
                            </body>
                        </html>
                    `,
        },
        Text: {
          Charset: "UTF-8",
          Data: `
                        New Travel Inquiry
                        
                        A new travel inquiry has been submitted with the following details:
                        
                        Reference ID: ${formData.id}
                        Name: ${formData.name}
                        Email: ${formData.email}
                        ${formData.phone ? `Phone: ${formData.phone}` : ""}
                        ${
                          formData.destination
                            ? `Destination: ${formData.destination}`
                            : ""
                        }
                        ${
                          formData.travelDateStart
                            ? `Travel Dates: ${formData.travelDateStart} to ${
                                formData.travelDateEnd || "TBD"
                              }`
                            : ""
                        }
                        ${
                          formData.travelers
                            ? `Travelers: ${formData.travelers}`
                            : ""
                        }
                        Message: ${formData.message || "No message provided"}
                        Submitted At: ${formData.submittedAt}
                    `,
        },
      },
      Subject: {
        Charset: "UTF-8",
        Data: "New Travel Inquiry Submission",
      },
    },
    Source: FROM_EMAIL,
  };

  return ses.sendEmail(params).promise();
}
