# DVD Rental Star Schema

This project converts a DVD rental relational database schema to a star schema using SQL. The star schema is a data model that is optimized for data warehousing and business intelligence. It is an effective way to represent complex data relationships in a more intuitive and easily readable format.

## Tables

The star schema has four dimension tables and one fact table.

### Dimension Tables

1. **DimDate:** This table holds information about the date of each transaction. It contains the `date key`, `date`, `year`, `quarter`, `month`, `day`, `week`, and information on whether the date falls on a weekend.
2. **DimCustomer:** This table contains information about each customer. It includes the customer `key`, `customer ID`, `first` and `last name`, `email`, `address`, `district`, `city`, `country`, `postal code`, `phone`, and information on whether the customer is active.
3. **DimFilm:** This table holds information about each film. It includes the `film key`, `film ID`, `title`, `description`, `release year`, `language`, `original language`, `rental duration`, `length`, `rating`, and `special features`.
4. **DimStore:** This table contains information about each store. It includes the `store key`, `store ID`, `address`, `district`, `city`, `country`, `postal code`, manager's `first` and `last name`, and the `start` and `end` dates of the store's operations.

## Data Insertion

The data is inserted into the tables using the SQL code provided in the project. The data is extracted from the relational database tables and transformed into the star schema tables. The data is then loaded into the star schema tables using the `INSERT` statement.

## Conclusion

The star schema provides a more intuitive and effective way to represent complex data relationships. By converting the DVD rental relational database schema to a star schema, it becomes easier to understand the relationships between the data and perform analysis. This project demonstrates how to create a star schema using SQL and insert data into the tables.
