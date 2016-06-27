import org.jpl7.Atom;
import org.jpl7.Query;
import org.jpl7.Term;

import INF1771_GameAI.Bot;

public class main {

	public static void main(String[] args) {
		Query q1 = new Query("consult", new Term[] {new Atom("Prolog/MainProlog.pl")});
		System.out.println("consult " + (q1.hasSolution() ? "succeeded" : "failed"));
		Bot b = new Bot();
	}

}
