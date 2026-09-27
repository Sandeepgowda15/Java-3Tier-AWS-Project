<%@ page contentType="text/html;charset=UTF-8" %>

<!DOCTYPE html>
<html>
<head>
    <title>Register</title>
</head>
<body>

    <h1>Create Account</h1>

    <form method="post"
          action="${pageContext.request.contextPath}/register">

        <input type="hidden"
               name="${_csrf.parameterName}"
               value="${_csrf.token}">

   <label>First Name:</label>
<input type="text"
       name="firstName"
       value="${employee.firstName}"
       required>
<br><br>

<label>Last Name:</label>
<input type="text"
       name="lastName"
       value="${employee.lastName}"
       required>
<br><br>

<label>Email:</label>
<input type="email"
       name="email"
       value="${employee.email}"
       required>
<br><br>

<label>Username:</label>
<input type="text"
       name="username"
       value="${employee.username}"
       required>
<br><br>

<label>Password:</label>
<input type="password"
       name="password"
       required>
<br><br>

        <button type="submit">Register</button>

    </form>

    <br>

    <% if (request.getAttribute("message") != null) { %>
        <p>
            <strong>${message}</strong>
        </p>
    <% } %>

    <% if (request.getAttribute("org.springframework.validation.BindingResult.employee") != null) { %>

        <ul>

            <% 
                org.springframework.validation.BindingResult result =
                    (org.springframework.validation.BindingResult)
                    request.getAttribute(
                        "org.springframework.validation.BindingResult.employee"
                    );

                for (org.springframework.validation.FieldError error :
                        result.getFieldErrors()) {
            %>

                <li>
                    <strong><%= error.getField() %>:</strong>
                    <%= error.getDefaultMessage() %>
                </li>

            <% } %>

        </ul>

    <% } %>

    <a href="${pageContext.request.contextPath}/login">
        Already have an account? Login
    </a>

</body>
</html>
