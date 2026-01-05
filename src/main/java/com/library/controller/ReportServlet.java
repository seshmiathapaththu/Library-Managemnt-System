package com.library.controller;

import com.library.dao.ReportDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/ReportServlet")
public class ReportServlet extends HttpServlet {
    private ReportDAO reportDAO = new ReportDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String type = request.getParameter("type");
        if (type == null) type = "summary";

        try {
            switch (type) {
                case "overdue":
                    request.setAttribute("reportTitle", "Overdue Books List");
                    request.setAttribute("data", reportDAO.getOverdueBooks());
                    break;
                case "history":
                    request.setAttribute("reportTitle", "Transaction History");
                    request.setAttribute("data", reportDAO.getIssueHistory());
                    break;
                case "logs":
                    request.setAttribute("reportTitle", "User Access Logs");
                    request.setAttribute("data", reportDAO.getLoginLogs());
                    break;
                case "payments":
                    request.setAttribute("reportTitle", "Payment Transactions");
                    request.setAttribute("data", reportDAO.getPaymentHistory());
                    break;
                default:
                    request.setAttribute("reportTitle", "Dashboard Summary");
                    break;
            }
            request.getRequestDispatcher("/reports_fragment.jsp").forward(request, response);
        } catch (Exception e) {
            response.getWriter().write("Error: " + e.getMessage());
        }
    }
}