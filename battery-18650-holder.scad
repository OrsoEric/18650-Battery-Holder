include <libs/polyround.scad>

include <libs/shape_petal.scad>

include <battery-18650.scad>

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
module half_support_18650( ir_inner, ir_thickness, il_support, ia_section )
{
    aan_points =
	([
        //Origin
        [0,0,0],
        [0,ir_thickness,0],
		[-ir_inner*0.75,ir_thickness,3],
        [-ir_inner*0.9,-0.2*ir_inner,0],
        [-ir_inner*0.4,0,0],
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

//Support around a full battery
module full_support_18650(ir_inner, ir_thickness, il_support, ia_section)
{

    half_support_18650(ir_inner, ir_thickness, il_support, ia_section);


    //left wing
    translate([il_support,0,0])
    rotate([0,0,180])
    half_support_18650(ir_inner, ir_thickness, il_support, ia_section);
    //full_support_18650( gd_18650_support/2, nw_base, gl_18650_support, ga_18650_support);
}

//metal contact for the terminals of the battery
module contact_18650( in_precision = 0.5 )
{
    nw_metal_tab_drill = 2.0;
    //Height  of the larger drill to accomodate the spring
    nh_metal_tab_spring = 4.0;
    //Full height of the extrusion for the metal tab
    nh_metal_tab = gd_18650_support+gw_18650_support;

    difference()
    {
        union()
        {
            //Cylinder cap
            //rotate and move the cylinder inside the holder
            translate([0,0,gd_18650_support/2+gw_18650_support])
            rotate([0,90,0])
            //Construct cylinder
            linear_extrude( gw_18650_cap )
            circle( d=gd_18650_support, $fa = in_precision, $fs =in_precision );

        }
        //Drill a space for the contacts
        union()
        {
            //Drill for the spring of the metal tab
            //Move the drill
            translate([gw_18650_cap-nw_metal_tab_drill,0,0])
            //Thin drill for the metal tabs
            translate([0,-gl_metal_tab/2,nh_metal_tab-nh_metal_tab_spring])
            linear_extrude(nh_metal_tab_spring)
            square([nw_metal_tab_drill,gl_metal_tab]);
            
            //Drill for the body of the metal tab buried in the support cap
            //Move the drill
            translate([gw_18650_cap-gw_metal_tab-nw_metal_tab_drill,0,0])
            //Thin drill for the metal tabs
            translate([0,-gl_metal_tab/2,0])
            linear_extrude(nh_metal_tab)
            square([gw_metal_tab,gl_metal_tab]);
            
        }
    }
}

//Instance holder for a signle 18650 battery
module single_18650_holder
(
	ix_show_battery = true
)
{
    nl_base = 50;

    //battery
    if (ix_show_battery == true)
    {
        translate([(gl_18650_support-gl_18650)/2,0,gw_18650_support])
        battery_18650(ix_sideway = 1);
    }
    
    //I use two sets of wings
    //short wings to retain the battery aligned
    //Tall wings to clip the battery in place

    //Retaining wing butt
    color("red")
    full_support_18650( gd_18650_support/2, gw_18650_support, gl_18650_support/6, ga_18650_support);

    //Retaining wing front
    color("red")
    translate([gl_18650_support *(5/6),0,0])
    full_support_18650( gd_18650_support/2, gw_18650_support, gl_18650_support/6, ga_18650_support);

    //Support wing
    color("red")
    full_support_18650( gd_18650_support/2, gw_18650_support, gl_18650_support, ga_18650_guide);

    //Front cap
    contact_18650();

    //Rear cap
    translate([gl_18650_support -0*gw_18650_cap,0,0])
    rotate([0,0,180])
    contact_18650();
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


single_18650_holder( ix_show_battery = false );
//single_18650_holder( ix_show_battery = true );


//double_18650_holder();

//holder_18650_2s2p( ix_show_battery = false );

