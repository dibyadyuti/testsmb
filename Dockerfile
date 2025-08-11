# Use AWS Glue 4.0 base image
FROM public.ecr.aws/glue/aws-glue-libs:glue_libs_4.0.0_image_01

# Switch to root for package installation
USER root

# Install build tools and headers (no groupinstall)
RUN yum install -y \
        gcc \
        libffi-devel \
        python3-devel \
        zip \
    && yum clean all

# Install specific versions of the Python libraries
RUN /usr/local/bin/pip3 install --no-cache-dir \
    cryptography==3.4.8 \
    smbprotocol==1.10.1

# Verify imports to confirm they're working
# Verify the libraries are installed and importable
RUN python3 -c "import cryptography.hazmat.bindings._openssl, smbprotocol; \
print('✅ cryptography and smbprotocol are importable!')"

# Build offline wheels and zip them
RUN mkdir -p /tmp/build && \
    pip3 download --only-binary=:all: \
        cryptography==3.4.8 \
        smbprotocol==1.10.1 \
        -d /tmp/build && \
    cd /tmp/build && \
    zip -r9 /tmp/smbprotocol_wheels.zip .

# Default working directory
WORKDIR /home/glue_user
