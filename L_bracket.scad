
bracketWidth = 35;
bracketWidthSpaced = bracketWidth + 0.5;
bracketThickness = 3.5;

//mountHeight = 50;
mountThickness = 2.4;
//Must be >= teethSize
endStop1 = 3.2;
grooveOffset = 2;

//Height of teeth; triangle base is double the height
teethSize = 2;
//A half-tooth will be added to this
numTeeth = 12;
teethThickness = 2.7;
teethBacking = 3.2;

holeDia = 5;
//from top of mount to center of hole
topHoleVOffset = 10;
//from top of mount to center of hole
bottomHoleVOffset = 31;
//horizontal distance between center of holes; set to 0 for a single centered hole.
topHoleHOffset = 21;
//horizontal distance between center of holes; set to 0 for a single centered hole.
bottomHoleHOffset = 0;

raThickness = 2.4;

numBarTeeth = 3;

mountHeight = (numTeeth+1) * (teethSize*2);
mountWidth = bracketWidthSpaced + 2*(teethSize + teethBacking);

e = 0.001;

module bracketEnd() {
    cube(size=[endStop1, mountThickness + bracketThickness + e, mountHeight]);
}

module tooth() {
    //backing
    cube(size=[teethBacking, teethThickness, teethSize*2]);
    
    //color([255/255, 0/255, 0/255])
    translate([teethSize + teethBacking, 0, teethSize])
    rotate([0, 0, 90])
    prism(teethThickness, teethSize, teethSize);
    
    //color([255/255, 0/255, 0/255])
    translate([teethBacking, 0, 0])
    rotate([90, 0, 90])
    prism(teethThickness, teethSize, teethSize);
}

//provides a printable angled groove for the retention arm to slide on
module angleGroove(grooveHeight) {
    //color([0/255, 0/255, 255/255])
    rotate([0, -90, 0])
    prism(grooveHeight, teethBacking/2, teethBacking);
}

module teeth() {
    for (i=[0:numTeeth]) { //makes one extra; gonna cut one in half
        translate([0, 0, i * (teethSize*2)])
        tooth();
    }
    
    //extra overlap with endstop
    translate([0, -grooveOffset, 0])
    cube(size=[teethThickness, grooveOffset, mountHeight]);
    
    translate([teethBacking, -teethBacking/2-grooveOffset, 0])
    angleGroove(mountHeight);
    
    
}

module hole() {
    rotate([90, 0, 0])
    cylinder(r1=holeDia/2+1, r2=holeDia/2, h=mountThickness+e, $fn=32);
}

module bracket() {
    
    //back
    difference() {
        cube(size=[bracketWidthSpaced, mountThickness, mountHeight]);
        
        //top right hole
        translate([bracketWidthSpaced/2-topHoleHOffset/2, mountThickness, mountHeight-topHoleVOffset])
        hole();
        
        //top left hole
        translate([bracketWidthSpaced/2+topHoleHOffset/2, mountThickness, mountHeight-topHoleVOffset])
        hole();
        
        //bottom right hole
        translate([bracketWidthSpaced/2-bottomHoleHOffset/2, mountThickness, mountHeight-bottomHoleVOffset])
        hole();
        
        //bottom left hole
        translate([bracketWidthSpaced/2+bottomHoleHOffset/2, mountThickness, mountHeight-bottomHoleVOffset])
        hole();
    }
    
    
    //end steps 1
    translate([bracketWidthSpaced, 0, 0])
    bracketEnd();
    
    translate([-endStop1, 0, 0])
    bracketEnd();
    
    //teeth
    translate([-endStop1-teethBacking + (endStop1-teethSize), mountThickness + bracketThickness, 0])
    teeth();
    
    mirror([1, 0, 0])
    translate([-bracketWidthSpaced-endStop1-teethBacking + (endStop1-teethSize), mountThickness + bracketThickness, 0])
    teeth();
}

module trimmedBracket() {
    difference() {
        bracket();
        
        translate([-endStop1-teethBacking-teethSize, -1, 0])
        cube(size=[bracketWidthSpaced*2, 10, teethSize]);
    }
}

module raSideArm(height) {
    grooveGap = 0.7;
    sideArmLen = teethThickness+grooveOffset+grooveGap+raThickness;
    
    cube(size=[raThickness, sideArmLen+teethBacking/2, 5*teethSize]);
    
    difference() {
        
        //Groove and backing
        union() {
            translate([raThickness, sideArmLen, 0])
            mirror([1, 0, 0])
            angleGroove(height);
            
            translate([0, sideArmLen+teethBacking/2, 0])
            cube(size=[teethBacking+raThickness, 1.2, height]);
        }
        
        //trim to account for overlap with endstop
        //color([0/255, 255/255, 0/255])
        translate([teethBacking + raThickness - (endStop1-teethSize), sideArmLen, 0])
        cube(size=[teethBacking+2, teethBacking+2, height+e]);
        
        echo(str("groove len = ", teethBacking + raThickness - (endStop1-teethSize)));
    }
}

module retainingArm() {
    mw = mountWidth + 0.5;
    raHeight = 5*teethSize;
    
    //back
    cube(size=[mw, raThickness, raHeight]);
    
    //tab
    translate([(mw - bracketWidth/3)/2, 2.4, raHeight-4])
    cube(size=[bracketWidth/3, 2.4 + 0.3, 4]);
    
    //arm
    translate([-raThickness, 0, 0])
    raSideArm(raHeight);
    
    //arm
    translate([mw+raThickness, 0, 0])
    mirror([1, 0, 0])
    raSideArm(raHeight);
}

module bar() {
    height = numBarTeeth * teethSize*2;
    
    difference() {
        cube(size=[bracketWidthSpaced, teethThickness, height]);
        
    }
    
    
    for (i=[0:numBarTeeth-1]) {
        translate([teethBacking, 0, i * (teethSize*2)])
        mirror([1, 0, 0])
        tooth();
    }
    
    for (i=[0:numBarTeeth-1]) {
        translate([-teethBacking+bracketWidthSpaced, 0, i * (teethSize*2)])
        tooth();
    }
}


translate([teethSize + teethBacking, 0, 0])
trimmedBracket();

translate([-0.25, mountThickness + bracketThickness + teethThickness + raThickness + 0.3, 10])
mirror([0, 1, 0])
retainingArm();

color([0/255, 255/255, 0/255])
translate([teethBacking+endStop1-teethSize+.75, mountThickness+bracketThickness, 10])
bar();


module prism(extrusion, width, h){
    polyhedron(
        points=[[0,0,0], [extrusion,0,0], [extrusion,width,0], [0,width,0], [0,width,h], [extrusion,width,h]],
        faces=[[0,1,2,3],[5,4,3,2],[0,4,5,1],[0,3,4],[5,2,1]]
    );
}
