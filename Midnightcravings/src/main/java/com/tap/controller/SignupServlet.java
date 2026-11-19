package com.tap.controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import com.tap.utility.DBConnection;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/signup")
public class SignupServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String username = request.getParameter("username");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String address = request.getParameter("address");

        if (username == null || email == null ||
            password == null || address == null) {
            response.sendRedirect(
                request.getContextPath() + "/Signup.jsp?error=1");
            return;
        }

        username = username.trim();
        email = email.trim();
        address = address.trim();

        if (username.isEmpty() || email.isEmpty() ||
            password.length() < 8 || address.isEmpty() ||
            username.length() > 45 || email.length() > 45 ||
            address.length() > 45) {
            response.sendRedirect(
                request.getContextPath() + "/Signup.jsp?error=1");
            return;
        }

        String checkSql =
            "SELECT userId FROM `user` " +
            "WHERE username = ? OR email = ?";

        String insertSql =
            "INSERT INTO `user` " +
            "(username, password, email, address, role, createDate) " +
            "VALUES (?, ?, ?, ?, 'customer', CURDATE())";

        try (Connection con = DBConnection.getConnection()) {

            try (PreparedStatement check =
                     con.prepareStatement(checkSql)) {

                check.setString(1, username);
                check.setString(2, email);

                try (ResultSet rs = check.executeQuery()) {
                    if (rs.next()) {
                        response.sendRedirect(
                            request.getContextPath()
                            + "/Signup.jsp?error=exists");
                        return;
                    }
                }
            }

            try (PreparedStatement insert =
                     con.prepareStatement(insertSql)) {

                insert.setString(1, username);
                insert.setString(2, password);
                insert.setString(3, email);
                insert.setString(4, address);

                insert.executeUpdate();
            }

            response.sendRedirect(
                request.getContextPath()
                + "/Login.jsp?message=signupSuccess");

        } catch (SQLException e) {
            throw new ServletException(
                "Unable to register the account.", e);
        }
    }
}
