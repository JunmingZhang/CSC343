import java.sql.*;
import java.util.List;

// If you are looking for Java data structures, these are highly useful.
// Remember that an important part of your mark is for doing as much in SQL (not Java) as you can.
// Solutions that use only or mostly Java will not receive a high mark.
import java.util.ArrayList;
//import java.util.Map;
//import java.util.HashMap;
//import java.util.Set;
//import java.util.HashSet;
public class Assignment2 extends JDBCSubmission {

    public Assignment2() throws ClassNotFoundException {

        Class.forName("org.postgresql.Driver");
    }

    @Override
    public boolean connectDB(String url, String username, String password) {
        // Implement this method!
        try {
            // get connection to the database by the given url, username and password
            connection = DriverManager.getConnection(url, username, password);
            // set path to the schema parlgov
            connection.setSchema("parlgov");
            return true;
        } catch (SQLException se) {
            System.err.println("SQL Exception." +
                        "<Message>: " + se.getMessage());
            return false;
        }
    }

    @Override
    public boolean disconnectDB() {
        // Implement this method!
        try {
            // disconnect from the server
            connection.close();
            return true;
        } catch (SQLException se) {
            System.err.println("SQL Exception." +
                        "<Message>: " + se.getMessage());
            return false;
        }
    }

    @Override
    public ElectionCabinetResult electionSequence(String countryName) {
        // Implement this method!
        ElectionCabinetResult result = null;
        try {
            // used for initialize ElectionCabinetResult to return
            List<Integer> elections = new ArrayList<Integer>();
            List<Integer> cabinets = new ArrayList<Integer>();

            // text of the query
            String sqlText = "SELECT el.id AS electionId, ca.id AS cabinetId " +
                             "FROM cabinet ca, election el, country co " +
                             "WHERE co.name = ? AND " +
                             "co.id = ca.country_id AND " +
                             "el.id = ca.election_id " +
                             "ORDER BY (EXTRACT(year FROM e_date)) DESC";

            // execute the query
            PreparedStatement ps = connection.prepareStatement(sqlText);
            ps.setString(1, countryName);
            ResultSet rs = ps.executeQuery();

            // get the data from the result after executing the sql
            while (rs.next()) {
                elections.add(rs.getInt("electionId"));
                cabinets.add(rs.getInt("cabinetId"));
            }
            // initialize the result needed to return
            result = new ElectionCabinetResult(elections, cabinets);
        } catch (SQLException se) {
            System.err.println("SQL Exception." +
                        "<Message>: " + se.getMessage());
        }
        return result;
    }

    @Override
    public List<Integer> findSimilarPoliticians(Integer politicianName, Float threshold) {
        // Implement this method!
        try {
            // get the description and comment of the selected politician
            String selectedDescription = null;
            String selectedComment = null;

            // initialize the list for results
            List<Integer> result = new ArrayList<Integer>();

            // query for getting the description and the comment of the selected politician
            String selectedPoliticianSQL = "SELECT description AS description1, comment AS comment1 " +
                                           "FROM politician_president poli_pr " +
                                           "WHERE poli_pr.id = ?";
    
            // execute the first query
            PreparedStatement ps1 = connection.prepareStatement(selectedPoliticianSQL);
            ps1.setInt(1, politicianName);
            ResultSet rs1 = ps1.executeQuery();

            // get the description and the comment of the selected politician
            while (rs1.next()) {
                selectedDescription = rs1.getString("description1");
                selectedComment = rs1.getString("comment1");
            }

            // query for getting the politicians with similiar comments and descriptions
            String selectedOtherPoliticiansSQL = "SELECT description AS description2, comment AS comment2, poli_pr.id AS PrId " +
                                                "FROM politician_president poli_pr " +
                                                "WHERE poli_pr.id <> ?";
            
            // execute the second query
            PreparedStatement ps2 = connection.prepareStatement(selectedOtherPoliticiansSQL);
            ps2.setInt(1, politicianName);
            ResultSet rs2 = ps2.executeQuery();

            // get the result
            while (rs2.next()) {
                int PrId = rs2.getInt("PrId");
                if (similarity(selectedDescription, rs2.getString("description2")) +
                    similarity(selectedComment, rs2.getString("comment2")) > threshold) {
                        result.add(PrId);
                    }
            }

            return result;
        } catch (SQLException se) {
            System.err.println("SQL Exception." +
                        "<Message>: " + se.getMessage());
            return null;
        }
    }

    public static void main(String[] args) {
        // You can put testing code in here. It will not affect our autotester.
        System.out.println("Hello");
    }

}

