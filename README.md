**SMB Access with AWS Glue 4.0 in Docker**

**Overview**
This project demonstrates how to extend the AWS Glue 4.0 Docker image with the necessary Python dependencies to connect to SMB (Server Message Block) shares using the smbprotocol library. It also covers installing supporting modules like cryptography and pyspnego to handle encryption and authentication.

The setup allows you to:

Build a custom Glue image with SMB support.

Verify that required Python modules are available.

Package wheels for reuse in AWS Glue jobs.

Test SMB connections locally before deploying to AWS.

****

**1. Base Image**
We use the official AWS Glue 4.0 base image:

dockerfile
Copy
Edit
FROM public.ecr.aws/glue/aws-glue-libs:glue_libs_4.0.0_image_01
This image contains Glue runtime dependencies but does not include smbprotocol or other SMB-related packages by default.


**2. Installing System Dependencies**
Some Python packages (like cryptography) need system-level build tools and libraries:

dockerfile
Copy
Edit
RUN yum groupinstall -y "Development Tools" && \
    yum install -y gcc libffi-devel python3-devel zip && \
    yum clean all

**3. Installing Python Packages**
We install:

cryptography – Required for secure communication.

smbprotocol – Python SMB client library.

pyspnego – Handles SPNEGO/Kerberos authentication.

Example:

dockerfile
Copy
Edit
RUN pip3 install --no-cache-dir \
    cryptography==3.4.8 \
    smbprotocol==1.10.1 \
    pyspnego

**4. Verifying Installations**
We use a small inline Python script to check:


dockerfile
Copy
Edit
RUN python3 - <<'PYCODE'
try:
    import cryptography.hazmat.bindings._openssl
    import smbprotocol
    import pyspnego
    print("✅ All SMB dependencies are importable!")
except Exception as e:
    print("❌ Dependency check failed:", e)
PYCODE

**5. Packaging Wheels for AWS Glue**
AWS Glue jobs often run in a restricted environment, so we package our dependencies into .whl files:

dockerfile
Copy
Edit
RUN mkdir -p /tmp/build && \
    pip3 download --only-binary=:all: \
        cryptography==3.4.8 \
        smbprotocol==1.10.1 \
        pyspnego \
        -d /tmp/build && \
    cd /tmp/build && \
    zip -r9 /tmp/smbprotocol_wheels.zip .
We can copy this ZIP from the container:

bash
Copy
Edit
docker cp my_smb_container:/tmp/smbprotocol_wheels.zip .

**6. Sample SMB Connection Script**
python
Copy
Edit
import smbprotocol

try:
    smbprotocol.ClientConfig(username="DOMAIN\\user", password="pass")
    print("SMB protocol version:", smbprotocol.__version__)
except Exception as e:
    print("Error connecting to SMB:", e)

**7. Run the Container****
bash
Copy
Edit
docker build -t glue-smb-builder .
docker run -it glue-smb-builder bash
