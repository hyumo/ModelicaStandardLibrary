within Modelica.Electrical.QuasiStatic.SinglePhase.Sensors;
model CurrentSensor "Current sensor"
  extends Modelica.Electrical.QuasiStatic.SinglePhase.Interfaces.TwoPinElementary;
  extends Modelica.Icons.RoundSensor;
  Modelica.ComplexBlocks.Interfaces.ComplexOutput i(re(unit = "A"), im(unit = "A")) "Complex current" annotation (Placement(
        transformation(
        origin={0,-110},
        extent={{-10,-10},{10,10}},
        rotation=270), iconTransformation(
        extent={{-10,-10},{10,10}},
        rotation=270,
        origin={0,-110})));
  Modelica.SIunits.Voltage abs_i=Modelica.ComplexMath.abs(i) "Magnitude of complex current";
  Modelica.SIunits.Angle arg_v=Modelica.ComplexMath.arg(v) "Argument of complex current";
  Modelica.SIunits.ComplexVoltage v "Complex voltage";
equation
  i = pin_p.i;
  Complex(0,0) = pin_p.i + pin_n.i "Current balance";
  v = pin_p.v - pin_n.v;
  v = Complex(0,0);
  annotation (Documentation(info="<html>
<p>
This sensor can be used to measure the complex current.
</p>

<h4>See also</h4>

<p>
<a href=\"modelica://Modelica.Electrical.QuasiStatic.SinglePhase.Sensors.ReferenceSensor\">ReferenceSensor</a>,
<a href=\"modelica://Modelica.Electrical.QuasiStatic.SinglePhase.Sensors.FrequencySensor\">FrequencySensor</a>,
<a href=\"modelica://Modelica.Electrical.QuasiStatic.SinglePhase.Sensors.PotentialSensor\">PotentialSensor</a>,
<a href=\"modelica://Modelica.Electrical.QuasiStatic.SinglePhase.Sensors.VoltageSensor\">VoltageSensor</a>,
<a href=\"modelica://Modelica.Electrical.QuasiStatic.SinglePhase.Sensors.PowerSensor\">PowerSensor</a>,
<a href=\"modelica://Modelica.Electrical.QuasiStatic.SinglePhase.Sensors.MultiSensor\">MultiSensor</a>
</p>

</html>"),
       Icon(graphics={
        Text(
          extent={{-30,-10},{30,-70}},
          textColor={64,64,64},
          textString="A"),
        Text(
          extent={{-150,130},{150,90}},
          textString="%name",
          textColor={0,0,255})}));
end CurrentSensor;
