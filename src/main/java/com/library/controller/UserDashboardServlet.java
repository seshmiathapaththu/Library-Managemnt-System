package com.library.controller;

import com.library.dao.BookDAO;
import com.library.model.Book;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet("/UserDashboardServlet")
public class UserDashboardServlet extends HttpServlet {
    private BookDAO bookDAO = new BookDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String query = request.getParameter("searchQuery");
        List<Book> bookList;


        if (query != null && !query.trim().isEmpty()) {

            bookList = bookDAO.searchBooks(query, "All Categories", "All");
        } else {

            bookList = bookDAO.getAllBooks();
        }

        request.setAttribute("bookList", bookList);

        request.getRequestDispatcher("user_dashboard.jsp").forward(request, response);
    }
}