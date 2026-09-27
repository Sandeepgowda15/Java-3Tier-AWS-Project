<%@ page contentType="text/html;charset=UTF-8" %>

<!DOCTYPE html>
<html>
<head>
    <title>Login</title>
</head>
<body>

    <h1>Login</h1>

    <% if (request.getParameter("error") != null) { %>
        <p>
            <strong>Invalid username or password.</strong>
        </p>
    <% } %>

    <% if (request.getParameter("logout") != null) { %>
        <p>
            <strong>You have been logged out successfully.</strong>
        </p>
    <% } %>

    <form method="post"
          action="${pageContext.request.contextPath}/login">

        <input type="hidden"
               name="${_csrf.parameterName}"
               value="${_csrf.token}">

        <label>Username:</label>
        <input type="text"
               name="username"
               required>

        <br><br>

        <label>Password:</label>
        <input type="password"
               name="password"
               required>

        <br><br>

        <button type="submit">Login</button>

    </form>

    <br>

    <a href="${pageContext.request.contextPath}/register">
        Create an account
    </a>

    <br><br>

    <a href="${pageContext.request.contextPath}/">
        Back to Home
    </a>

</body>
</html>
