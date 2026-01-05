package com.library.controller;

import com.library.dao.TransactionDAO;
import com.library.model.Transaction;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet("/IssueReturnServlet")
public class IssueReturnServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        TransactionDAO dao = new TransactionDAO();
        List<Transaction> transactions = dao.getAllTransactions();

        request.setAttribute("transactions", transactions);
        request.getRequestDispatcher("issue_return.jsp").forward(request, response);
    }
}