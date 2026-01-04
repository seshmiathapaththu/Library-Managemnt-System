package com.library.controller;

import com.library.util.DBConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.Properties;
import java.util.logging.Level;
import java.util.logging.Logger;

// Jakarta Mail Imports
import jakarta.mail.*;
import jakarta.mail.internet.*;

@WebServlet("/AddMemberServlet")
public class AddMemberServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(AddMemberServlet.class.getName());

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String name = request.getParameter("name");
        String username = request.getParameter("username");
        String email = request.getParameter("email");
        String defaultPassword = "123456";

        try {
            try (Connection conn = DBConnection.getConnection()) {
                String sql = "INSERT INTO users (name, username, email, password, role_id, status) VALUES (?, ?, ?, ?, 3, 'Active')";
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setString(1, name);
                    ps.setString(2, username);
                    ps.setString(3, email);
                    ps.setString(4, defaultPassword);

                    int result = ps.executeUpdate();
                    if (result > 0) {
                        // Capture the result of the email send
                        boolean isEmailSent = sendWelcomeEmail(email, name, username);

                        if (isEmailSent) {
                            response.sendRedirect("LibrarianDashboardServlet?tab=users&success=Member_Registered_and_Email_Sent");
                        } else {
                            // User added to DB, but SMTP failed
                            response.sendRedirect("LibrarianDashboardServlet?tab=users&error=User_Added_But_Email_Failed_Check_Console");
                        }
                    } else {
                        response.sendRedirect("LibrarianDashboardServlet?tab=users&error=Registration_Failed");
                    }
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Database error during registration", e);
            response.sendRedirect("LibrarianDashboardServlet?tab=users&error=User_Already_Exists");
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Unexpected server error", e);
            response.sendRedirect("LibrarianDashboardServlet?tab=users&error=Server_Error");
        }
    }

    private boolean sendWelcomeEmail(String recipientEmail, String fullName, String accountUsername) {
        // SMTP Settings
        final String senderEmail = "primemode0005@gmail.com";
        final String senderPassword = "bozepsdmpmormzwq";

        Properties props = new Properties();
        // Core SMTP settings
        props.put("mail.smtp.host", "smtp.gmail.com");
        props.put("mail.smtp.port", "587");
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.starttls.required", "true");

        // Security protocols
        props.put("mail.smtp.ssl.protocols", "TLSv1.2");
        props.put("mail.smtp.ssl.trust", "smtp.gmail.com");

        // Connection timeouts
        props.put("mail.smtp.connectiontimeout", "10000"); // 10 seconds
        props.put("mail.smtp.timeout", "10000");

        Session session = Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(senderEmail, senderPassword);
            }
        });

        // Debug mode is ON
        session.setDebug(true);

        try {
            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(senderEmail));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(recipientEmail));
            message.setSubject("Your Library Account Credentials");

            // Refined email body as requested
            String emailContent = "<div style='font-family: Arial, sans-serif; border: 1px solid #ddd; padding: 20px; border-radius: 10px;'>"
                    + "<h2 style='color: #2c3e50;'>Welcome to the Library, " + fullName + "!</h2>"
                    + "<p>Your account has been created. Use the credentials below to log in:</p>"
                    + "<div style='background: #fdfdfd; padding: 15px; border: 1px solid #eee; display: inline-block;'>"
                    + "<strong>Username:</strong> " + accountUsername + "<br>"
                    + "<strong>Password:</strong> 123456"
                    + "</div>"
                    + "<div style='margin-top: 20px; color: #e74c3c; border: 2px solid #e74c3c; padding: 10px; border-radius: 5px; font-weight: bold;'>"
                    + "⚠️ IMPORTANT: Please change your password immediately after your first login for security."
                    + "</div>"
                    + "<p style='color: #7f8c8d; font-size: 12px; margin-top: 20px;'>Library Management System Team</p>"
                    + "</div>";

            message.setContent(emailContent, "text/html");
            Transport.send(message);

            LOGGER.log(Level.INFO, "Email sent successfully to {0}", recipientEmail);
            return true;

        } catch (MessagingException e) {

            e.printStackTrace();
            LOGGER.log(Level.SEVERE, "SMTP failure for " + recipientEmail + ": " + e.getMessage());
            return false;
        }
    }
}