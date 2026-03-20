import java.sql.Connection;
import java.sql.DriverManager;

public class DBManager {
    public static Connection getConnection() throws Exception {
        String url = "jdbc:sqlserver://localhost\\SQLEXPRESS;databaseName=ITI_Exam_System;integratedSecurity=true;encrypt=true;trustServerCertificate=true;";
        return DriverManager.getConnection(url);
    }
}