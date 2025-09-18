//Mini pupper
//Belly plate for 3D printing

include <polyround.scad>

//Dimensions
//Global Length
gl_minipupper_belly = 181.0;
//Global Width
gw_minipupper_belly = 60.0;
//Global height
gh_minipupper_belly = 1.0;

//Drill pattern
gpl_drill_front = 0.5*(51.5+55.7);
gpl_drill_center = 0.5*(60.1+64.3)-0.25;
gpl_drill_rear = 0.5*(51.4+55.8);
gpw_drill = 0.5*(44.6+49.0);
//Margin drill border
gml_drill_front = 7.0;
gml_drill_rear = 4.0;
gm2_drill = 6.5;

//Global Diameter
gd_minipupper_belly_drill = 2.0 +0.3;
//Global Pitch Length/Width
gpl_minipupper_belly_drill = 10 *8 /2;
gpw_minipupper_belly_drill = 6 *8;

module drill( ind, inz, in_precision = 0.5 )
{
    linear_extrude(inz)
    circle( d=ind, $fa=in_precision, $fs=in_precision );
}

module mini_pupper_belly( inr_rounding = 6.0, in_precision = 0.5 )
{
    
    aan_points =
	([
        [0, -0.5*gw_minipupper_belly, inr_rounding],
        [0, +0.5*gw_minipupper_belly, inr_rounding],
		[+gl_minipupper_belly, +0.5*gw_minipupper_belly, inr_rounding],
		[+gl_minipupper_belly, -0.5*gw_minipupper_belly, inr_rounding],
    ]);
	
    difference()
    {
        union()
        {
            linear_extrude(gh_minipupper_belly)
            polygon(polyRound(aan_points,100));
        }
        union()
        {
			//Front Drills
			translate([gml_drill_front,0.5*gpw_drill,0])
			drill(gd_minipupper_belly_drill, gh_minipupper_belly, in_precision);
			translate([gml_drill_front,-0.5*gpw_drill,0])
			drill(gd_minipupper_belly_drill, gh_minipupper_belly, in_precision);

			//Center Front Drills
			translate([gml_drill_front+gpl_drill_front,0.5*gpw_drill,0])
			drill(gd_minipupper_belly_drill, gh_minipupper_belly, in_precision);
			translate([gml_drill_front+gpl_drill_front,-0.5*gpw_drill,0])
			drill(gd_minipupper_belly_drill, gh_minipupper_belly, in_precision);

			//Center Rear Drills
			translate([gml_drill_front+gpl_drill_front+gpl_drill_center,0.5*gpw_drill,0])
			drill(gd_minipupper_belly_drill, gh_minipupper_belly, in_precision);
			translate([gml_drill_front+gpl_drill_front+gpl_drill_center,-0.5*gpw_drill,0])
			drill(gd_minipupper_belly_drill, gh_minipupper_belly, in_precision);

			//Rear Drills
			translate([gml_drill_front+gpl_drill_front+gpl_drill_center+gpl_drill_rear,0.5*gpw_drill,0])
			drill(gd_minipupper_belly_drill, gh_minipupper_belly, in_precision);
			translate([gml_drill_front+gpl_drill_front+gpl_drill_center+gpl_drill_rear,-0.5*gpw_drill,0])
			drill(gd_minipupper_belly_drill, gh_minipupper_belly, in_precision);	        
        }
    }
    
	
    
}

//mini_pupper_belly();