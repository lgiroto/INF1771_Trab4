package INF1771_GameAI;
import INF1771_GameAI.Map.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.stream.Collectors;

import org.jpl7.Query;


public class GameAI
{
    Position player = new Position();
    String state = "ready";
    String dir = "north";
    long score = 0;
    int energy = 0;

    
    /**
     * Refresh player status
     * @param x			player position x
     * @param y			player position y
     * @param dir		player direction
     * @param state		player state
     * @param score		player score
     * @param energy	player energy
     */
    public void SetStatus(int x, int y, String dir, String state, long score, int energy)
    {
        player.x = x;
        player.y = y;
        this.dir = dir.toLowerCase();

        this.state = state;
        this.score = score;
        this.energy = energy;
        
        Query defPos = new Query("def_pos(" + player.x + "," + player.y + "," + dir + ")");
    	defPos.oneSolution();
    	System.out.println("(" + player.x + "," + player.y + "," + dir + ")");
    }

    /**
     * Get list of observable adjacent positions
     * @return List of observable adjacent positions 
     */
    public List<Position> GetObservableAdjacentPositions()
    {
        List<Position> ret = new ArrayList<Position>();

        ret.add(new Position(player.x - 1, player.y));
        ret.add(new Position(player.x + 1, player.y));
        ret.add(new Position(player.x, player.y - 1));
        ret.add(new Position(player.x, player.y + 1));

        return ret;
    }

    /**
     * Get list of all adjacent positions (including diagonal)
     * @return List of all adjacent positions (including diagonal)
     */
    public List<Position> GetAllAdjacentPositions()
    {
        List<Position> ret = new ArrayList<Position>();

        ret.add(new Position(player.x - 1, player.y - 1));
        ret.add(new Position(player.x, player.y - 1));
        ret.add(new Position(player.x + 1, player.y - 1));

        ret.add(new Position(player.x - 1, player.y));
        ret.add(new Position(player.x + 1, player.y));

        ret.add(new Position(player.x - 1, player.y + 1));
        ret.add(new Position(player.x, player.y + 1));
        ret.add(new Position(player.x + 1, player.y + 1));

        return ret;
    }

    /**
     * Get next forward position
     * @return next forward position
     */
    public Position NextPosition()
    {
        Position ret = null;
        if(dir.equals("north"))
                ret = new Position(player.x, player.y - 1);
        else if(dir.equals("east"))
                ret = new Position(player.x + 1, player.y);
        else if(dir.equals("south"))
                ret = new Position(player.x, player.y + 1);
        else if(dir.equals("west"))
                ret = new Position(player.x - 1, player.y);

        return ret;
    }

    /**
     * Player position
     * @return player position
     */
    public Position GetPlayerPosition()
    {
        return player;
    }
    
    /**
     * Set player position
     * @param x		x position
     * @param y		y position
     */
    public void SetPlayerPosition(int x, int y)
    {
        player.x = x;
        player.y = y;

    }

    /**
     * Observations received
     * @param o	 list of observations
     */
    public void GetObservations(List<String> o)
    {
    	Query action;
		HashMap solution;
    	
        for (String s : o)
        {
        	System.out.println("Observado: " + s);
        	if(s.equals("blocked")){
        		action = new Query("add_obstaculo");
        		action.allSolutions();         	
            } else if(s.equals("steps") || s.contains("enemy")){
            	action = new Query("avistar_inimigo");
        		action.oneSolution();  
            } else if(s.equals("breeze")){
            	action = new Query("add_problema");
        		action.allSolutions();        
            } else if(s.equals("flash")){
            	action = new Query("add_problema");
        		action.allSolutions();        
            } else if(s.equals("blueLight")){
            	action = new Query("add_pu");
        		action.allSolutions();   
            } else if(s.equals("redLight")){
            	action = new Query("add_item");
        		action.allSolutions();  
            } else if(s.equals("weakLight")){
            	action = new Query("add_item");
        		action.allSolutions(); 
            }
        }
        if(!o.contains("breeze") && !o.contains("flash") && !o.contains("blocked")){
        	action = new Query("arredores_livres(" + player.x + "," + player.y + ")");
    		action.allSolutions();
    	}
    }

    /**
     * No observations received
     */
    public void GetObservationsClean()
    {
    	Query al = new Query("arredores_livres(" + player.x + "," + player.y + ")");
		al.allSolutions();
    }

    /**
     * Get Decision
     * @return command string to new decision
     */
    public String GetDecision()
    {
    	Query q5 = new Query("acao(X)");
		HashMap solution = (HashMap) q5.oneSolution();
		if(solution != null){
			String Action = solution.get("X").toString();
			System.out.println(Action);
			
			if(Action.equals("pegar_item") || Action.equals("pegar_powerup")){
				Query pegar = new Query("pegar");
				pegar.oneSolution();
			} else if(Action.equals("atacar")){
				Query atirar = new Query(Action);
				atirar.oneSolution();
			}
			
			return Action;
		}
    	return "";
    }
}
