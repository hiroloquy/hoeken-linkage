reset

#=================== Functions ====================
# Position of 5 joints
r = 1
Ox = 0
Oy = 0
Ax(t) = r*cos(t)
Ay(t) = r*sin(t)
Bx = 2*r
By = 0
Cx(t) = (2+cos(t))*r/2 + r*sin(t)*sqrt((5+cos(t))/(5-4*cos(t)))
Cy(t) = r*sin(t)/2 + r*(2-cos(t))*sqrt((5+cos(t))/(5-4*cos(t)))
Dx(t) = 2*r + 2*r*sin(t)*sqrt((5+cos(t))/(5-4*cos(t)))
Dy(t) = 2*r*(2-cos(t))*sqrt((5+cos(t))/(5-4*cos(t)))

# Round off to the i decimal place.
round(x, i) = 1 / (10.**(i+1)) * floor(x * (10.**(i+1)) + 0.5)

#=================== Calculation ====================
# Prepare DAT file
outputfile = 'outputfile.dat'
set print outputfile

set angle degrees
DEG_DIV = 4.0    # Resolution of degree, increase by 1/DEG_DIV

# Write items and parameters in outputfile
print '#deg / Ox Oy / Ax Ay / Bx By / Cx Cy / Dx Dy / straight or curve'
print sprintf('# r=%.2f, DEG_DIV=%d', r, DEG_DIV)

# Calculate and output position of joints in outputfile
do for[i=0:360*DEG_DIV:1]{
    deg = i/DEG_DIV
    line = ' c'  # default: curve

    # Whether D's motion is approximate straight-line or not at θ = deg
    if(deg > 55 && deg < 305){
        cnt = 0
        do for [j=-2:2:1]{   # Compare Dy(deg) with Dy(deg+j)
            if(j!=0 && abs(Dy(deg)-Dy(deg+j)) < r*1e-2){
                cnt = cnt + 1
            }
        }
        if(cnt == 4){
            line = ' s'  # D's motion is approximate straight-line at θ = deg
        }
    }
 
    # Output deg, position of joints, whether line is straight or curve
    print deg, Ox, Oy, round(Ax(deg), 2), round(Ay(deg), 2), Bx, By, \
        round(Cx(deg), 2), round(Cy(deg), 2), round(Dx(deg), 2), round(Dy(deg), 2), line
}

unset print
print "Finish calculation!" # Notice

#=================== Plot ====================
# Setting
set term gif animate delay 6 size 720, 720
set output 'Hoeken Linkage.gif'
set xr[-2:5]
set yr[-2:6]
set xl 'x' font 'TimesNewRoman:Italic, 20'
set yl 'y' font 'TimesNewRoman:Italic, 20'
set size ratio -1
unset key
set grid

CIRC_R = 0.1    # Radius of joints

# Draw fixed joints
set obj 1 circ at Ox, Oy size CIRC_R fc rgb 'black' fs solid front
set obj 2 circ at Bx, By size CIRC_R fc rgb 'black' fs solid front
set label 1 'O' left at Ox+0.1, Oy-0.3 font 'TimesNewRoman:Italic, 20' front
set label 2 'B' left at Bx+0.1, By-0.3 font 'TimesNewRoman:Italic, 20' front

# Output gif
LOOP = 2    # Number of animation loop
do for[i=0:360*DEG_DIV*LOOP:DEG_DIV]{
    deg = int(i/DEG_DIV)%360

    set title sprintf("{/:Italic θ} = %d°", deg) font 'TimesNewRoman, 20'

    # Draw unfixed joints
    posAx = Ax(deg) ; posAy = Ay(deg)
    posCx = Cx(deg) ; posCy = Cy(deg)
    posDx = Dx(deg) ; posDy = Dy(deg)
    set obj 3 circ at posAx, posAy size CIRC_R fc rgb 'black' fs solid front
    set obj 4 circ at posCx, posCy size CIRC_R fc rgb 'black' fs solid front
    set obj 5 circ at posDx, posDy size CIRC_R fc rgb 'black' fs solid front
    set label 3 'A' left at posAx+0.2, posAy-0.3 font 'TimesNewRoman:Italic, 20' front
    set label 4 'C' left at posCx-0.4, posCy+0.2 font 'TimesNewRoman:Italic, 20' front
    set label 5 'D' left at posDx+0.1, posDy+0.2 font 'TimesNewRoman:Italic, 20' front

    # Draw links
    set arrow 1 from Ox, Oy to posAx, posAy nohead lw 4 front
    set arrow 2 from posAx, posAy to posDx, posDy nohead lw 4 front
    set arrow 3 from Bx, By to posCx, posCy nohead lw 4 front

    if(i < 360*DEG_DIV){
        end = i  # Show part of the trajectory
     } else {
        end = 360*DEG_DIV # Show all the trajectory
     }

     plot outputfile u 4:((stringcolumn(12) eq "c" ) ? $5 : 1/0) every ::::end w l lw 3 lc rgb 'royalblue', \
          outputfile u 4:((stringcolumn(12) eq "s" ) ? $5 : 1/0) every ::::end w l lw 3 lc rgb 'red', \
          outputfile u 8:9 every ::::i w l lw 3 lc rgb 'forest-green', \
          outputfile u 10:((stringcolumn(12) eq "c" ) ? $11 : 1/0) every ::::end w l lw 3 lc rgb 'royalblue', \
          outputfile u 10:((stringcolumn(12) eq "s" ) ? $11 : 1/0) every ::::end w l lw 3 lc rgb 'red'
}
set out
print "Finish plot!" # Notice