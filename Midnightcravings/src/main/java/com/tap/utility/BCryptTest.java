package com.tap.utility;

import org.mindrot.jbcrypt.BCrypt;

public class BCryptTest {
    public static void main(String[] args) {

        String password = "test123";

        // Convert the password into a BCrypt hash
        String hashedPassword = BCrypt.hashpw(
            password,
            BCrypt.gensalt()
        );

        System.out.println("Hashed password: " + hashedPassword);

        // Verify the password
        System.out.println(
            "Password matches: " +
            BCrypt.checkpw(password, hashedPassword)
        );
    }
}
