//Contact the 18650 Battery
//I have several styles of contacts

//Cylinder with precision
include <libs/shape_cylinder.scad>

//Smmoth cone
include <libs/shape_truncated_cone_rounded.scad>

//spring
//10x10x8

//bump
//10x10x1

module battery_18650_tab_spring
(
	//Metal plate
	i_l_plate = 10,
	i_w_plate = 10,
	i_t_plate = 0.1,
	//Locking features
	i_l_lock = 2,
	i_w_lock = 1,
	i_h_lock = 1,
	//Battery Spring
	i_d_hole = 1.75,
	i_wi_hole = 8,
	//Total height with spring
	i_h_tab = 8,
	//Size of the spring
	i_d_base = 6,
	i_d_tip = 5,
	//Precision of the circles
	i_e_precision = 0.01
)
{
	color("#999999")
	difference()
	{
		//ADD
		union()
		{
			//Metal Plate
			translate([0,0,i_t_plate/2])
			cube([i_l_plate,i_w_plate, i_t_plate],center=true);
			//Spring feature
			translate([0,0,i_t_plate/2])
			truncated_cone
			(
				i_r_bot = i_d_base/2,
				i_r_top_delta = (i_d_tip-i_d_base)/2,
				i_h = i_h_tab,
				i_r_edge_rounding = i_d_base/20 
			);

			//Lock features
			ap_lock_section = 
			[
				//length, height
				[-i_l_lock/2,0],
				[i_l_lock/2,0],
				[i_l_lock/2,i_h_lock]
			];

			for (l_offset = [-(i_l_plate/2-i_w_lock/2),+(i_l_plate/2-i_w_lock/2)])
				translate([l_offset,0,i_t_plate])
				rotate([-90,180,90])
				linear_extrude(i_w_lock,center=true)
				polygon(ap_lock_section);


		}	//END ADD
		//SUB
		union()
		{
			//Drill the metal plate, this is for the contacts
			for (w_offset = [i_wi_hole/2,-i_wi_hole/2])
			translate([0,w_offset,0])
			shape_cylinder
			(
				i_d = i_d_hole,
				i_h = i_t_plate,
				i_e = i_e_precision
			);
		}	//END SUB
	}	//End difference
} //End Module: battery_18650_tab_spring

//TEST
//battery_18650_tab_spring();

if (false)
battery_18650_tab_spring
(
	//Metal plate
	i_l_plate = 10,
	i_w_plate = 10,
	i_t_plate = 0.1,
	//Locking features
	i_l_lock = 2,
	i_w_lock = 1,
	i_h_lock = 1,
	//Battery Spring
	i_d_hole = 1.75,
	i_wi_hole = 8,
	//Total height with spring
	i_h_tab = 8,
	//Size of the spring
	i_d_base = 6,
	i_d_tip = 5,
	//Precision of the circles
	i_e_precision = 0.01
);