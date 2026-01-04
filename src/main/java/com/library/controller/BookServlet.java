package com.library.controller;

import com.library.dao.BookDAO;
import com.library.model.Book;
import com.library.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/BookServlet")
public class BookServlet extends HttpServlet {
    private BookDAO bookDAO = new BookDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doPost(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        String isLibrarian = request.getParameter("isLibrarian");

        // 1. Get current session user
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");

        // 2. Determine redirect page based on roleId == 2
        String redirectPage = "admin_dashboard.jsp"; // Default to Admin
        if (currentUser != null && currentUser.getRoleId() == 2) {
            redirectPage = "librarian_dashboard.jsp";
        }

        try {
            if ("add".equals(action)) {
                Book newBook = new Book();
                newBook.setTitle(request.getParameter("title"));
                newBook.setAuthor(request.getParameter("author"));
                newBook.setIsbn(request.getParameter("isbn"));
                newBook.setCategory(request.getParameter("category"));

                int copies = Integer.parseInt(request.getParameter("copies"));
                newBook.setTotalCopies(copies);
                newBook.setAvailableCopies(copies);

                if (bookDAO.addBook(newBook)) {
                    response.sendRedirect(redirectPage + "?success=book_added");
                } else {
                    response.sendRedirect(redirectPage + "?error=add_failed");
                }

            } else if ("delete".equals(action)) {
                int bookId = Integer.parseInt(request.getParameter("bookId"));
                boolean deleted = bookDAO.deleteBook(bookId);

                // Handle AJAX Deletion for Librarian Dashboard
                if ("true".equals(isLibrarian)) {
                    if (deleted) {
                        response.setStatus(HttpServletResponse.SC_OK);
                    } else {
                        response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Database deletion failed");
                    }
                    return;
                } else {
                    // Standard redirect logic
                    response.sendRedirect(redirectPage + "?success=" + (deleted ? "book_deleted" : "fail"));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            if ("true".equals(isLibrarian)) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid input");
            } else {
                response.sendRedirect(redirectPage + "?error=invalid_input");
            }
        }
    }
}