within Modelica.Electrical;
package Analog "Library for analog electrical models"
  import SI = Modelica.SIunits;

  extends Modelica.Icons.Package;

  annotation (Documentation(info="<html>
<p>
This package contains packages for single phase electrical components, see
<a href=\"modelica://Modelica.Electrical.Analog.UsersGuide\">User's Guide</a></p>
</html>"), Icon(graphics={
        Line(
          points={{12,60},{12,-60}}),
        Line(
          points={{-12,60},{-12,-60}}),
        Line(points={{-80,0},{-12,0}}),
        Line(points={{12,0},{80,0}})}));
end Analog;
