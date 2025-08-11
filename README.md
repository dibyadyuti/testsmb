**SMB Access with AWS Glue 4.0 in Docker**

**Overview**
This project demonstrates how to extend the AWS Glue 4.0 Docker image with the necessary Python dependencies to connect to SMB (Server Message Block) shares using the smbprotocol library. It also covers installing supporting modules like cryptography and pyspnego to handle encryption and authentication.

The setup allows you to:

Build a custom Glue image with SMB support.

Verify that required Python modules are available.

Package wheels for reuse in AWS Glue jobs.

Test SMB connections locally before deploying to AWS.
