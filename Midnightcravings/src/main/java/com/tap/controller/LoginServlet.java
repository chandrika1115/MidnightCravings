package com.tap.controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import com.tap.utility.DBConnection;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

public class LoginServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    /**
     * Handles GET requests to /login.
     * Redirects the user to the login page.
     */
    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        response.sendRedirect(
            request.getContextPath() + "/Login.jsp"
        );
    }

    /**
     * Handles login form submissions.
     */
    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String username = request.getParameter("username");
        String password = request.getParameter("password");

        String contextPath = request.getContextPath();

        // Validate the submitted credentials.
        if (username == null || password == null
                || username.trim().isEmpty()
                || password.isEmpty()) {

            response.sendRedirect(
                contextPath + "/Login.jsp?error=1"
            );
            return;
        }

        String sql =
            "SELECT userId, username, email, role " +
            "FROM user " +
            "WHERE (username = ? OR email = ?) " +
            "AND password = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, username.trim());
            ps.setString(2, username.trim());
            ps.setString(3, password);

            try (ResultSet rs = ps.executeQuery()) {

                // Invalid username or password.
                if (!rs.next()) {
                    response.sendRedirect(
                        contextPath + "/Login.jsp?error=1"
                    );
                    return;
                }

                int userId = rs.getInt("userId");
                String loggedInUsername =
                    rs.getString("username");
                String email = rs.getString("email");
                String role = rs.getString("role");

                // Create or retrieve the session.
                HttpSession session = request.getSession();

                // Prevent session fixation after successful login.
                request.changeSessionId();

                // Store authenticated user information.
                session.setAttribute("userId", userId);
                session.setAttribute("username", loggedInUsername);
                session.setAttribute("email", email);
                session.setAttribute("role", role);

                // Session expires after 30 minutes of inactivity.
                session.setMaxInactiveInterval(30 * 60);

                // Redirect according to the user's role.
                if ("restaurant".equalsIgnoreCase(role)) {

                    session.removeAttribute("redirectAfterLogin");

                    response.sendRedirect(
                        contextPath + "/restaurant-dashboard"
                    );

                } else if ("deliveryagent".equalsIgnoreCase(role)) {

                    session.removeAttribute("redirectAfterLogin");

                    response.sendRedirect(
                        contextPath + "/delivery-agent-dashboard"
                    );

                } else if ("customer".equalsIgnoreCase(role)) {

                    String redirectAfterLogin =
                        (String) session.getAttribute(
                            "redirectAfterLogin"
                        );

                    if (redirectAfterLogin != null
                            && redirectAfterLogin.startsWith(
                                contextPath + "/")) {

                        session.removeAttribute("redirectAfterLogin");

                        response.sendRedirect(redirectAfterLogin);

                    } else {

                        session.removeAttribute("redirectAfterLogin");

                        response.sendRedirect(
                            contextPath + "/home"
                        );
                    }

                } else if ("superad".equalsIgnoreCase(role)) {

                    // Admin dashboard is not configured here.
                    response.sendRedirect(
                        contextPath + "/Login.jsp?error=1"
                    );

                } else {

                    // Invalidate the session for an unsupported role.
                    session.invalidate();

                    response.sendRedirect(
                        contextPath + "/Login.jsp?error=1"
                    );
                }
            }

        } catch (SQLException e) {

            throw new ServletException(
                "Unable to process login.",
                e
            );
        }
    }
}