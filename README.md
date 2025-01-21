# Pool Manager - Sirius Challenge
## Description
This project is a solution to the Sirius Challenge. The project is a pool manager that allows the user to create, update, delete and list players and matches. The project was developed using Ruby on Rails.

## Setup & Installation
To run the project, you need to have **Ruby** and **Rails** installed on your machine. You can follow the instructions on the [official website](https://guides.rubyonrails.org/getting_started.html#prerequisites) to install Ruby and Rails. 

### Versions
- Ruby version: 3.4.1
- Rails version: 8.0.1
- PostgreSQL version: 1.1
- Puma version: 5.0

This app was created using ```rails new pool-manager-challenge --api```

After installing Ruby and Rails, you can clone the repository and run the following commands to install the dependencies:

```bash
bundle install
```

## Database Setup
The project uses PostgreSQL as the database. You need to have PostgreSQL installed on your machine. You can follow the instructions on the [official website](https://www.postgresql.org/download/) to install PostgreSQL.

To create the database, you can run the following commands:
```bash
rails db:create
rails db:migrate
```

## Environment Variables
The project uses the ```dotenv``` gem to manage environment variables. You need to create a ```.env``` file in the root directory of the project and add the following variables:

### Database
```
DATABASE_PASSWORD
DATABASE_URL
```

### Azure Blob Storage
You need to create an Azure Storage Account and a container to store the blobs. You can follow the instructions on the [official documentation](https://docs.microsoft.com/en-us/azure/storage/blobs/).
```
AZURE_STORAGE_ACCOUNT_NAME
AZURE_STORAGE_CONTAINER_NAME
```
You also need to add the Azure Storage Account key into Rails credentials. You can run the following command to edit the credentials:
```bash
EDITOR=<YOUR_EDITOR> bin/rails credentials:edit
```
Add the following lines to the credentials file:
```yaml
azure_storage:
  storage_access_key: <YOUR_AZURE_STORAGE_ACCOUNT_KEY>
```

## Running the Project
After installing the dependencies, creating the database, and setting the environment variables, you can run the project using the following command:

```bash
rails s
```