package com.library.controller;

import com.library.util.DBConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;

@WebServlet("/AddBookServlet")
public class AddBookServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Capture parameters
        String title = request.getParameter("title");
        String author = request.getParameter("author");
        String isbn = request.getParameter("isbn");
        String category = request.getParameter("category");
        String copiesStr = request.getParameter("copies");

        // Validate inputs are not empty
        if (title == null || title.trim().isEmpty() ||
                author == null || author.trim().isEmpty() ||
                isbn == null || isbn.trim().isEmpty() ||
                copiesStr == null || copiesStr.trim().isEmpty()) {
            response.sendRedirect("LibrarianDashboardServlet?tab=books&error=EmptyFields");
            return;
        }

        try (Connection conn = DBConnection.getConnection()) {
            int totalCopies = Integer.parseInt(copiesStr.trim());
            int availableCopies = totalCopies; // Initially, all copies are available

            // Set status based on your database Enum ('Available', 'Low Stock', 'Out of Stock')
            String status = (totalCopies > 0) ? "Available" : "Out of Stock";

            // 3. SQL Query matching your provided schema
            String sql = "INSERT INTO books (title, author, isbn, category, total_copies, available_copies, status) VALUES (?, ?, ?, ?, ?, ?, ?)";

            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, title);
                ps.setString(2, author);
                ps.setString(3, isbn);
                ps.setString(4, category);
                ps.setInt(5, totalCopies);
                ps.setInt(6, availableCopies);
                ps.setString(7, status);

                int rowsInserted = ps.executeUpdate();
                if (rowsInserted > 0) {
                    // Success
                    response.sendRedirect("LibrarianDashboardServlet?tab=books&success=BookAdded");
                } else {
                    response.sendRedirect("LibrarianDashboardServlet?tab=books&error=InsertFailed");
                }
            }
        } catch (NumberFormatException e) {
            response.sendRedirect("LibrarianDashboardServlet?tab=books&error=InvalidQuantity");
        } catch (Exception e) {
            e.printStackTrace(); // Check your IDE console for the specific SQL error here
            response.sendRedirect("LibrarianDashboardServlet?tab=books&error=DatabaseError");
        }
    }
}