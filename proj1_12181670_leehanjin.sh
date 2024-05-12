#! /bin/bash

check_arguments() {
	if [ $# -ne 3 ]; then
		echo "Three arguments are required"
		exit 1
	fi

	for arg in "$@"
	do
		if [[ ! "$arg" =~ \.csv$ ]]; then
        	echo "Each argument must be a CSV file name."
		exit 1
	fi
	TEAMS=$1
	PLAYERS=$2
	MATCHES=$3
	done
}

get_user_input() {
	echo ""
	echo "[MENU]"
	echo "1. Get the data of Heung-Min Son's Current Club, Appearances, Goals, Assists in players.csv"
	echo "2. Get the team data to enter a league position in teams.csv"
	echo "3. Get the Top-3 Attendance matches in mateches.csv"
	echo "4. Get the team's league position and team's top scorer in teams.csv & players.csv"
	echo "5. Get the modified format of date_GMT in matches.csv"
	echo "6. Get the data of the winning team by the largest difference on home stadium in teams.csv & matches.csv"
	echo "7. Exit"
	read -p "Enter your CHOICE (1~7) : " reply
}

query_son_data() {
	read -p "Do you want to get the Heung-min Son's data? (y/n): " answer
	if [ "$answer" = "y" ]; then
        	cat $PLAYERS | awk -F, '$1 == "Heung-Min Son" {printf "Team: %s, Appearance: %s, Goal: %s, Assist: %s\n", $4, $6, $7, $8}'
	fi
}

query_team_of_ranking(){
	read -p "What do you want to get the team data of league_position[1~20]: " answer
	cat $TEAMS | awk -F, -v answer="$answer" '$6==answer {printf "%s %s %f\n\n",$6, $1, $2/($2+$3+$4)}'
}

query_top_attendance_matches(){
	read -p "Do you want to know Top-3 attendance data and average attendance? (y/n): " answer
        if [ "$answer" = "y" ]; then
		echo "***Top-3 Attendance Match***"
		echo ""
		cat $MATCHES| tail -n +2 | sort -t ',' -k 2 -n -r| head -n 3 | awk -F, '{printf "%s vs %s (%s)\n%s %s\n\n", $3, $4, $1, $2, $7}'
	fi
}

query_team_info(){
	read -p "Do you want to get each team's ranking and the highest-scoring player? (y/n): " answer
        if [ "$answer" = "y" ]; then
		sorted_teams=$(cat $TEAMS | tail -n +2 | sort -t ',' -k 6 -n)
	
		IFS=','
		echo "$sorted_teams" | while read -r team_name wins draws losses points ranking other_fields
		do
			echo ""
			echo "$ranking $team_name"
			highest_goals=0
			top_scorer=$(awk -F',' -v team="$team_name" '
	    			$4 == team { 
        				if ($7 > highest_goals) { 
            					highest_goals=$7; 
            					result=$1" "$7;
       	 				} 
   	 			}	
    			END { print result }
			' $PLAYERS)
			echo "$top_scorer"
		done
	fi
}

query_match_date(){
	read -p "Do you want to modify the format of date? (y/n): " answer
        if [ "$answer" = "y" ]; then
		cat $MATCHES | tail -n +2 | head -n 10 | sed -E '
			s/Jan/01/g;
			s/Feb/02/g;
			s/Mar/03/g;
			s/Apr/04/g;
			s/May/05/g;
			s/Jun/06/g;
			s/Jul/07/g;
			s/Aug/08/g;
			s/Sep/09/g;
			s/Oct/10/g;
			s/Nov/11/g;
			s/Dec/12/g;
			s/^(([^,]*),.*)$/\1/;
			s/([0-9]{2}) ([0-9]{1,2}) ([0-9]{4}) - ([0-9]{1,2}:[0-9]{2}(am|pm))/\3\/\1\/\2 \4/'
	fi
}

query_largest_diff_matches(){
	teams=(
		"Arsenal"
		"Tottenham Hotspur"
   		"Manchester City"
   		"Leicester City"
  		"Crystal Palace"
  		"Everton"
  		"Burnley"
   		"Southampton"
    		"AFC Bournemouth"
    		"Manchester United"
		"Liverpool"
		"Chelsea"
		"West Ham United"
		"Watford"
		"Newcastle United"
		"Cardiff City"
		"Fulham"
		"Brighton & Hove Albion"
		"Huddersfield Town"
		"Wolverhampton Wanderers"
	)


	for (( i=0; i<10; i+=1 )); do
		printf "%-2d) %-20s %-2d) %-20s\n" $((i+1)) "${teams[i]}" $((i+11)) "${teams[i+10]}"
	done
	read -p "Enter your team number: " answer
	cat $MATCHES | awk -v ans="${teams[answer-1]}" -F, '
	BEGIN {
	    	max_diff = -1;  
	}
	$3 == ans {
    		diff = $5 - $6; 
    		if (diff > max_diff) {
        		max_diff = diff;
        		delete lines;
    		}
    		if (diff == max_diff) {
        		lines[NR] = $1 "\n" $3 " " $5 " vs " $6 " " $4 "\n";
		}
	}
	END {
		print("\n");
    		for (i in lines) {
	        	print lines[i];
    		}
	}'
}


check_arguments $@

echo "************OSS1 - Project1************"
echo "*         StudentID : 12181670        *"
echo "*         Name : Hanjin Lee           *"
echo "***************************************"

while true
do
        get_user_input
	case "$reply" in
	1)
		query_son_data;;
	2)
		query_team_of_ranking;;
	3)
		query_top_attendance_matches;;
	4)
		query_team_info;;
	5)
		query_match_date;;
	6)
		query_largest_diff_matches;;
	7)
		break;;
	esac
done
