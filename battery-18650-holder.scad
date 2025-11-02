include <libs/polyround.scad>

include <libs/shape_petal.scad>

include <battery-18650.scad>

//Include the geometry for the tab that contact with the battery, and the endcap of the battery holder
include <battery-18650-tabs.scad>

//	2024-06-23
//	Printed but too short for the batteries


//Library to draw 18650 batteries
//Legend:
//gl = Global Length
//gw =
//gh

gl_18650 = 66.0;
gd_18650 = 18.4;
gl_18650_key = 3.0;
gd_18650_key = 10.0;

//Thickness of the cap
gw_18650_cap = 5.0;
//diameter of the holder with margin
gd_18650_support = gd_18650 +0.5;

//Length of the support. Accomodate battery, two caps, and margin for the springs
gl_18650_support = gl_18650 +2*gw_18650_cap +3;
gl_18650_support_2s = 2*gl_18650 +2*gw_18650_cap +3;
//Angle of the wing. controls how tall the support goes
ga_18650_support = 110;
ga_18650_guide = 60;
//hickness of the base and the walls
gw_18650_support = 3.0;
//interaxis between sideway batteries plus margin
gi_18650_double_support = gd_18650 +0.5;

//Length of the metal tab
gl_metal_tab = 12.0;
//Thickness of the metal tab
gw_metal_tab = 0.5;


//I make half support and drill the hole
//ia_section = controls the strength of the support. 0 is none. 90 comes up to half battery. the more up the more it retains, but the harder it is to insert
//Fixed the shape of the base to be more scalable with wall thickness, now works from 1 to 3
module half_support_18650
(
	ir_inner,
	ir_thickness,
	il_support,
	ia_section
)
{
    aan_points =
	([
        //Origin
        [0,0,0],
        [0,ir_thickness,0],
		[-ir_inner*0.5 -ir_thickness*0.7,ir_thickness,3],
        [-ir_inner*0.6 -ir_thickness*0.9,-0.2*ir_inner,0],
		[-ir_inner*0.3 -ir_thickness*0.4,-0.0*ir_inner,0],
        [-ir_inner*0.5 -ir_thickness*0.7,-0.0*ir_inner,0],
    ]);  

    //Place the base under the battery housing
    translate([0,0,ir_thickness])
    rotate([-90,0,-90])
    //Construct base
    linear_extrude(il_support)
    polygon(polyRound(aan_points,100));

	shape_petal
	(
		i_r_inner = ir_inner,
		i_r_thickness = ir_thickness,
		i_l_length =il_support,
		i_a_angle = ia_section,
		i_e = 0.01
	);
}

if (false)
half_support_18650
(
	ir_inner = (18.4+0.5)/2,
	ir_thickness = 1.0,
	il_support = 20,
	ia_section = 60
);


//Support around a full battery
module full_support_18650(ir_inner, ir_thickness, il_support, ia_section)
{
    half_support_18650(ir_inner, ir_thickness, il_support, ia_section);

    //left wing
    translate([il_support,0,0])
    rotate([0,0,180])
    half_support_18650(ir_inner, ir_thickness, il_support, ia_section);
}

//Instance holder for a signle 18650 battery
module single_18650_holder
(
	//	BATTERY
	//Diameter of the 18650 battery plus tollerance
	id_18650 = 18.4+0.5,
	//Length of the 18650 battery from base to button
	il_18650 = 71.0,

	//	TAB SPRING
	//Dimensions of the tab plate, plus tollerance
	il_tab = 11.0 +0.5,
	iw_tab = 11.0 +0.5,
	it_tab = 1.25,
	//Length of the tab spring, uncompressed
	il_tab_spring_unloaded = 8.0,
	//Length of the tab spring, fully compressed
	il_tab_spring_loaded = 3.0,
	//How much to compress the spring 0 = unloaded, 1 = loaded
	ilk_tab_spring_compression = 0.75,

	//	STRUCTURE
	//Thickness of the Holder walls
	it_wall = 1.5,
	
	//Angle of the cradle where the battery rests
	ia_cradle = 60,
	//Angle of the wings keeping the battery in place
	ia_wing = 120,
	
	//thickness of the cap back
	it_cap = 1.0,


	//	WIRE
	//Width of the wire slot
	iw_slot_wire = 4,

	//	SHOW EXTRA ELEMENTS
	//Show the battery model
	ix_show_battery = false,
	//Show battery tab spring
	ix_show_tab = false
)
{
    nl_base = 50;

	//Compute the spring compression length when battery is placed
	il_tab_spring = il_tab_spring_loaded + (il_tab_spring_unloaded -il_tab_spring_loaded)*(1-ilk_tab_spring_compression);
	
	echo("Spring loading",il_tab_spring);
	//Total length of the battery holder. account for the full stack
	l_total = il_18650 +il_tab_spring * 2 + it_cap * 2;

    //battery
    if (ix_show_battery == true)
    {
        translate([(l_total-il_18650)/2,0,it_wall])
        battery_18650
		(
			// Barrel Dimensions
			i_l_18650 = il_18650,
			i_d_18650 = id_18650-0.5,
			ix_sideway = 1
		);
    }
    
    //I use two sets of wings
    //short wings to retain the battery aligned
    //Tall wings to clip the battery in place

	difference()
	{
		union()
		{
			//Retaining wing butt
			color("red")
			full_support_18650
			(
				id_18650 / 2,
				it_wall,
				l_total / 8,
				ia_wing
			);

			//Retaining wing front
			color("red")
			translate([l_total *(7/8),0,0])
			full_support_18650
			(
				id_18650 / 2,
				it_wall,
				l_total / 8,
				ia_wing
			);

			//Retaining wing center
			color("red")
			translate([l_total *(3.5/8),0,0])
			full_support_18650
			(
				id_18650 / 2,
				it_wall,
				l_total / 8,
				ia_wing
			);

			//Support wing
			color("red")
			full_support_18650
			(
				id_18650/2,
				it_wall,
				l_total,
				ia_cradle
			);

			//Front cap
			translate([0,0,it_wall])
			battery_18650_contact_holder
			(
				//Size of the cylindrical endcap of the holder
				id_18650_cap = id_18650,
				it_18650_cap = 3,
				//Thickness of the material behind the cap
				it_cap_back = it_cap,
				//Size of the backplate of the tab with spring, this should include the tollerance
				il_tab = il_tab,
				iw_tab = iw_tab,
				//Size of the rails where the tab slots in. This should leave space for the spring itself
				iw_tab_rail = 2,
				//Thickness of the plate of the tab with spring, this should include the tollerance
				//There are two tiny inserts to lock the plate and need to slide in
				it_tab = it_tab,
				//Slot carved in the back to expose the plate for soldering
				il_slot_wire = 10,
				iw_slot_wire = iw_slot_wire,
				//Show the model of the tab spring
				ib_show_tab = ix_show_tab,
				//Precision of the circle
				ie_error = 0.01
			);

			//Rear cap
			translate([l_total,0,it_wall])
			rotate([0,0,180])
			battery_18650_contact_holder
			(
				//Size of the cylindrical endcap of the holder
				id_18650_cap = id_18650,
				it_18650_cap = 3,
				//Thickness of the material behind the cap
				it_cap_back = it_cap,
				//Size of the backplate of the tab with spring, this should include the tollerance
				il_tab = il_tab,
				iw_tab = iw_tab,
				//Size of the rails where the tab slots in. This should leave space for the spring itself
				iw_tab_rail = 2,
				//Thickness of the plate of the tab with spring, this should include the tollerance
				//There are two tiny inserts to lock the plate and need to slide in
				it_tab = it_tab,
				//Slot carved in the back to expose the plate for soldering
				il_slot_wire = 10,
				iw_slot_wire = iw_slot_wire,
				//Show the model of the tab spring
				ib_show_tab = ix_show_tab,
				//Precision of the circle
				ie_error = 0.01
			);
		}	//End Sum

		union()
		{
			//FRONT
			//Drill from the back space to solder the wire
			translate([0,0,it_wall*1.5/2])
			rotate([0,-90,180])
			linear_extrude(it_cap)
			square([it_wall*1.5,iw_slot_wire],center=true);

			//REAR
			//Drill from the back space to solder the wire
			translate([l_total+0.01,0,it_wall*1.5/2])
			rotate([0,-90,0])
			linear_extrude(it_cap)
			square([it_wall*1.5,iw_slot_wire],center=true);

		} //End Subtract

	} //End difference
	
}

module double_18650_holder( ix_show_battery = true )
{
    //width of the tall support
    nk_tall_support = 1/6;

    na_between = 60;
    //Distance betwenn the two batteries
    ni_between = gd_18650;
    
    //battery
    if (ix_show_battery == true)
    {
        translate([(gl_18650_support-gl_18650)/2,-gi_18650_double_support/2,gw_18650_support])
        battery_18650(ix_sideway = 1);


        translate([(gl_18650_support-gl_18650)/2,+gi_18650_double_support/2,gw_18650_support])
        battery_18650(ix_sideway = 1, in_invert_poles=true);
    }

    //build a tall wing on the right side of the right battery

    //Tall support
    translate([0,gi_18650_double_support/2,0])
    half_support_18650(gd_18650_support/2, gw_18650_support, gl_18650_support *nk_tall_support, ga_18650_support);

    //guide
    translate([gl_18650_support *nk_tall_support,gi_18650_double_support/2,0])
    half_support_18650(gd_18650_support/2, gw_18650_support, gl_18650_support *(1-2*nk_tall_support), ga_18650_guide );

    //Tall support
    translate([gl_18650_support *nk_tall_support *5,gi_18650_double_support/2,0])
    half_support_18650(gd_18650_support/2, gw_18650_support, gl_18650_support *nk_tall_support, ga_18650_support);

    //build a shorter wing on the left side of the right battery
    translate([0,-gi_18650_double_support/2,0])
    half_support_18650(gd_18650_support/2, gw_18650_support, gl_18650_support, na_between);
    
    //build a shorter wing on the right side of the left battery
    translate([gl_18650_support,gi_18650_double_support/2,0])
    rotate([0,0,180])
    half_support_18650(gd_18650_support/2, gw_18650_support, gl_18650_support, na_between);

    //build a tall wing on the left side of the left battery
    translate([gl_18650_support,-gi_18650_double_support/2,0])
    rotate([0,0,180])
    half_support_18650(gd_18650_support/2, gw_18650_support, gl_18650_support *nk_tall_support, ga_18650_support);

    //guide
    translate([gl_18650_support *(1-nk_tall_support),-gi_18650_double_support/2,0])
    rotate([0,0,180])
    half_support_18650(gd_18650_support/2, gw_18650_support, gl_18650_support *(1-2*nk_tall_support), ga_18650_guide );

    //Tall support
    translate([gl_18650_support *(1-5*nk_tall_support),-gi_18650_double_support/2,0])
    rotate([0,0,180])
    half_support_18650(gd_18650_support/2, gw_18650_support, gl_18650_support *(1-5*nk_tall_support), ga_18650_support );
    
}

module holder_18650_2s2p( ix_show_battery = true )
{
    //width of the tall support
    nk_tall_support = 1/20;
    //4K (1-4K)
    //1K  (1-4K)/2  2K  (1-4K)/2  1K
    // B      s      B      s      B

    na_between = 60;
    //Distance betwenn the two batteries
    ni_between = gd_18650;
    
    //battery
    if (ix_show_battery == true)
    {
        translate([(gl_18650_support-gl_18650)/2,-gi_18650_double_support/2,gw_18650_support])
        battery_18650(ix_sideway = 1);

        translate([(gl_18650_support-gl_18650)/2 +gl_18650,-gi_18650_double_support/2,gw_18650_support])
        battery_18650(ix_sideway = 1);

        translate([(gl_18650_support-gl_18650)/2,+gi_18650_double_support/2,gw_18650_support])
        battery_18650(ix_sideway = 1, in_invert_poles=true);
        
        translate([(gl_18650_support-gl_18650)/2 +gl_18650,+gi_18650_double_support/2,gw_18650_support])
        battery_18650(ix_sideway = 1, in_invert_poles=true);
    }

    //Tall support
    translate([0,gi_18650_double_support/2,0])
    half_support_18650(gd_18650_support/2, gw_18650_support, gl_18650_support_2s *nk_tall_support, ga_18650_support);

    //guide
    translate([gl_18650_support_2s *nk_tall_support,gi_18650_double_support/2,0])
    half_support_18650(gd_18650_support/2, gw_18650_support, gl_18650_support_2s *(1-4*nk_tall_support)/2, ga_18650_guide );

    //Tall support for two batteries
    translate([gl_18650_support_2s *(1*nk_tall_support+ (1-4*nk_tall_support)/2) ,gi_18650_double_support/2,0])
    half_support_18650(gd_18650_support/2, gw_18650_support, gl_18650_support_2s *2* nk_tall_support, ga_18650_support);

    //guide
    translate([gl_18650_support_2s *(1/2+nk_tall_support),gi_18650_double_support/2,0])
    half_support_18650(gd_18650_support/2, gw_18650_support, gl_18650_support_2s *(1-4*nk_tall_support)/2, ga_18650_guide );

    //Tall support for two batteries
    translate([gl_18650_support_2s *(1-nk_tall_support),gi_18650_double_support/2,0])
    half_support_18650(gd_18650_support/2, gw_18650_support, gl_18650_support_2s * nk_tall_support, ga_18650_support);

    //guide in between two batteries

    //build a shorter wing on the left side of the right battery
    translate([0,-gi_18650_double_support/2,0])
    half_support_18650(gd_18650_support/2, gw_18650_support, gl_18650_support_2s, na_between);
    
    //build a shorter wing on the right side of the left battery
    translate([gl_18650_support_2s,gi_18650_double_support/2,0])
    rotate([0,0,180])
    half_support_18650(gd_18650_support/2, gw_18650_support, gl_18650_support_2s, na_between);
    translate([gl_18650_support_2s,0,0])
    rotate([0,0,180])
    {
        //Tall support
        translate([0,gi_18650_double_support/2,0])
        half_support_18650(gd_18650_support/2, gw_18650_support, gl_18650_support_2s *nk_tall_support, ga_18650_support);

        //guide
        translate([gl_18650_support_2s *nk_tall_support,gi_18650_double_support/2,0])
        half_support_18650(gd_18650_support/2, gw_18650_support, gl_18650_support_2s *(1-4*nk_tall_support)/2, ga_18650_guide );

        //Tall support for two batteries
        translate([gl_18650_support_2s *(1*nk_tall_support+ (1-4*nk_tall_support)/2) ,gi_18650_double_support/2,0])
        half_support_18650(gd_18650_support/2, gw_18650_support, gl_18650_support_2s *2* nk_tall_support, ga_18650_support);

        //guide
        translate([gl_18650_support_2s *(1/2+nk_tall_support),gi_18650_double_support/2,0])
        half_support_18650(gd_18650_support/2, gw_18650_support, gl_18650_support_2s *(1-4*nk_tall_support)/2, ga_18650_guide );

        //Tall support for two batteries
        translate([gl_18650_support_2s *(1-nk_tall_support),gi_18650_double_support/2,0])
        half_support_18650(gd_18650_support/2, gw_18650_support, gl_18650_support_2s * nk_tall_support, ga_18650_support);
    }

    //Front cap
    translate([0,gi_18650_double_support/2,0])
    contact_18650();
    translate([0,-gi_18650_double_support/2,0])
    contact_18650();

    //Rear cap
    translate([gl_18650_support_2s -0*gw_18650_cap,gi_18650_double_support/2,0])
    rotate([0,0,180])
    contact_18650();
    translate([gl_18650_support_2s -0*gw_18650_cap,-gi_18650_double_support/2,0])
    rotate([0,0,180])
    contact_18650();
}

//single_18650_holder();

single_18650_holder( ix_show_battery = false, ix_show_tab = false );
	

//single_18650_holder( ix_show_battery = false );

//single_18650_holder( ix_show_battery = true );


//double_18650_holder();

//holder_18650_2s2p( ix_show_battery = false );

