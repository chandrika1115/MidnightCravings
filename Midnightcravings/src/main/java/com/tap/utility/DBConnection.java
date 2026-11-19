
package com.tap.utility;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConnection {

    private static final String URL =
            "jdbc:mysql://localhost:3306/food_deliveryapp";

    private static final String USERNAME = "root";
    private static final String PASSWORD = "Charika1115@";

    public static Connection getConnection() {

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");

            Connection connection =
                    DriverManager.getConnection(
                            URL,
                            USERNAME,
                            PASSWORD
                    );

            System.out.println("DB is connected");

            return connection;

        } catch (ClassNotFoundException e) {
            e.printStackTrace();
            throw new RuntimeException(
                    "MySQL JDBC Driver not found!", e
            );

        } catch (SQLException e) {
            e.printStackTrace();
            throw new RuntimeException(
                    "Database connection failed!", e
            );
        }
    }
}

