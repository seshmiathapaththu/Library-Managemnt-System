package com.library.controller;

import com.library.dao.*;
import com.library.model.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet("/LibrarianDashboardServlet")
public class LibrarianDashboardServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {


        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null || user.getRoleId() != 2) {
            response.sendRedirect("login.jsp");
            return;
        }


        String tab = request.getParameter("tab");
        if (tab == null) tab = "users";
        request.setAttribute("activeTab", tab);

        try {

            BookDAO bookDAO = new BookDAO();
            UserDAO userDAO = new UserDAO();
            TransactionDAO transDAO = new TransactionDAO();


            request.setAttribute("bookList", bookDAO.getAllBooks());
            request.setAttribute("userList", userDAO.getAllUsers());
            request.setAttribute("transList", transDAO.getAllTransactions());


            request.getRequestDispatcher("librarian_dashboard.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("error.jsp");
        }
    }
}