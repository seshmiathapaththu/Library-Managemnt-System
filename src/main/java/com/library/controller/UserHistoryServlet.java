package com.library.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

// Required for IO and Collections
import java.io.IOException;
import java.util.List;

// Required for your custom project classes
import com.library.dao.TransactionDAO;
import com.library.model.Transaction;
import com.library.model.User;

@WebServlet("/UserHistoryServlet")
public class UserHistoryServlet extends HttpServlet {


    private final TransactionDAO transDAO = new TransactionDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        if (user != null) {

            List<Transaction> history = transDAO.getUserHistory(user.getUserId());


            request.setAttribute("borrowHistory", history);


            request.getRequestDispatcher("user_dashboard.jsp").forward(request, response);
        } else {

            response.sendRedirect("login.jsp");
        }
    }
}