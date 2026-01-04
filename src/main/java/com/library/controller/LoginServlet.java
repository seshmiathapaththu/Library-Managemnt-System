package com.library.controller;

import com.library.dao.UserDAO;
import com.library.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String usernameInput = request.getParameter("username");
        String passwordInput = request.getParameter("password");
        String contextPath = request.getContextPath();

        UserDAO dao = new UserDAO();
        User validUser = dao.validate(usernameInput, passwordInput);

        if (validUser != null) {
            // Check if account is active
            if ("Deactivated".equalsIgnoreCase(validUser.getStatus())) {

                dao.logLoginAttempt(usernameInput, "Deactivated Account");
                response.sendRedirect(contextPath + "/index.jsp?error=deactivated");
                return;
            }


            dao.logLoginAttempt(usernameInput, "Success");

            HttpSession session = request.getSession();
            session.setAttribute("user", validUser);

            int roleId = validUser.getRoleId();

            if (roleId == 1) {
                response.sendRedirect(contextPath + "/admin_dashboard.jsp");
            } else if (roleId == 2) {
                response.sendRedirect(contextPath + "/librarian_dashboard.jsp");
            } else if (roleId == 3) {
                response.sendRedirect(contextPath + "/user_dashboard.jsp");
            } else {
                // LOG UNKNOWN ROLE
                dao.logLoginAttempt(usernameInput, "Unassigned Role Access Denied");
                response.sendRedirect(contextPath + "/index.jsp?error=unknown_role");
            }
        } else {

            dao.logLoginAttempt(usernameInput, "Failed - Invalid Credentials");
            response.sendRedirect(contextPath + "/index.jsp?error=invalid");
        }
    }
}