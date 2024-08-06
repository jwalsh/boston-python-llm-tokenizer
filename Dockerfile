# Use an official Python image as the base
FROM python:3.12-slim

# Set the working directory to /app
WORKDIR /app

# Install Emacs, make, and dependencies
RUN apt-get update && apt-get install -y emacs-nox imagemagick build-essential

# Install Poetry and dependencies
RUN pip install --upgrade pip poetry
RUN pip install --upgrade pip

# Create a new file for the poetry config
RUN poetry config virtualenvs.in-project true

# Copy the current directory contents into the container at /app
COPY . /app

# Install any needed packages specified in pyproject.toml
RUN poetry install
RUN touch .setup_complete
# Make port 80 available to the world outside this container
EXPOSE 80

# Define environment variable
ENV NAME Drill

# Run app.py when the container launches
CMD ["make", "drill"]