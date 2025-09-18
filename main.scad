//MiniPupper 2 battery plate with 18650 batteries
//2S 2P configuration

//TODO MP plate holes

include <minipupper-belly.scad>

include <libs/battery-18650.scad>

//
gpl_battery = 100;
gpw_battery = 20;

//Support for 18650
//size of the flat base
gpw_base = 10;
//Thickness of the base
gph_base = 2;
//Height of the battery retaining walls
//Taller more retantion but worse insertion experience
gph_retain = 10.0;

gpl_base= 0.1;

mini_pupper_belly();
translate([(gl_minipupper_belly -gl_18650_support_2s)/2,0,0])
holder_18650_2s2p( ix_show_battery = false );


if(false)
{
translate([0,0,gh_minipupper_belly])
union()
{
    //
    translate([gpl_battery-gl_18650,-gpw_battery/2,0])
    battery_18650(ix_sideway = 1);
    translate([gpl_battery,-gpw_battery/2,0])
    battery_18650(ix_sideway = 1);
    
    translate([gpl_battery-0*gl_18650,+gpw_battery/2,0])
    rotate([0,0,180])
    battery_18650(ix_sideway = 1);
    translate([gpl_battery+gl_18650,+gpw_battery/2,0])
    rotate([0,0,180])
    battery_18650(ix_sideway = 1);
}
}
//translate([200,0,0])
//half_support_18650();

//half_support_18650( 65/2, 3, 200, 100 );
