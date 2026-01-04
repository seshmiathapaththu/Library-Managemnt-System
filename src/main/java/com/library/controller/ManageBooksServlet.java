package com.library.controller;

import com.library.dao.BookDAO;
import com.library.model.Book;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;
import java.util.stream.Collectors;

@WebServlet("/ManageBooksServlet")
public class ManageBooksServlet extends HttpServlet {
    private BookDAO dao = new BookDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {


        String query = request.getParameter("searchQuery");
        List<Book> bookList = dao.getAllBooks();


        if (query != null && !query.trim().isEmpty()) {
            String lowerQuery = query.toLowerCase().trim();
            bookList = bookList.stream()
                    .filter(b -> b.getTitle().toLowerCase().contains(lowerQuery) ||
                            b.getIsbn().toLowerCase().contains(lowerQuery) ||
                            b.getAuthor().toLowerCase().contains(lowerQuery))
                    .collect(Collectors.toList());
        }


        request.setAttribute("bookList", bookList);
        request.getRequestDispatcher("books_fragment.jsp").forward(request, response);
    }
}