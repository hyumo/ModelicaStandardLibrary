within Modelica.Mechanics.Rotational.Components;
model Clutch "Clutch based on Coulomb friction"
  extends Modelica.Mechanics.Rotational.Icons.Clutch;
  extends Modelica.Mechanics.Rotational.Interfaces.PartialCompliantWithRelativeStates;

  import Modelica.Blocks.Types.{ExternalCombiTable1D, Extrapolation, Smoothness};
  import Modelica.Blocks.Tables.Internal.{getTable1DValue, getTable1DValueNoDer, getTable1DValueNoDer2};

  parameter Real mu_pos[:, 2] = [0, 0.5]
    "Positive sliding friction coefficient [-] as function of w_rel [rad/s] (w_rel>=0)";
  parameter Smoothness smoothness = Smoothness.LinearSegments
    "Smoothness of table interpolation in mu_pos";
  parameter Real peak(final min=1) = 1
    "Peak for maximum value of mu at w==0 (mu0_max = peak*mu_pos[1,2])";
  parameter Real cgeo(final min=0) = 1
    "Geometry constant containing friction distribution assumption";
  parameter SI.Force fn_max(final min=0, start=1) "Maximum normal force";

  extends Rotational.Interfaces.PartialFriction;
  extends Modelica.Thermal.HeatTransfer.Interfaces.PartialElementaryConditionalHeatPortWithoutT;

  Real mu "Friction coefficient";
  SI.Force fn "Normal force (fn=fn_max*f_normalized)";
  Modelica.Blocks.Interfaces.RealInput f_normalized
    "Normalized force signal 0..1 (normal force = fn_max*f_normalized; clutch is engaged if > 0)"
    annotation (Placement(transformation(origin={0,110}, extent={{20,-20},{-20,20}}, rotation=90)));

protected
  final parameter ExternalCombiTable1D tableID = ExternalCombiTable1D(
    tableName="NoName",
    fileName="NoName",
    table=mu_pos,
    columns={2},
    smoothness=smoothness,
    extrapolation=Extrapolation.LastTwoPoints,
    verboseRead=false) "External table object for sliding friction coefficient";
  final parameter Real mu0 =
    if     smoothness == Smoothness.ConstantSegments then getTable1DValueNoDer(tableID, 1, 0)
    elseif smoothness == Smoothness.LinearSegments   then getTable1DValueNoDer2(tableID, 1, 0)
    else                                                  getTable1DValue(tableID, 1, 0)
    "Friction coefficient for w=0 and forward sliding" annotation(Evaluate = true);

  Real table_signs[2]
    "Signs for sliding friction coefficient table interpolation: [sign for w_rel, sign for mu]";

equation
  assert(size(mu_pos, 1) > 0 and size(mu_pos, 2) > 0, "Parameter mu_pos is an empty matrix");

  // Relative quantities
  w_relfric = w_rel;
  a_relfric = a_rel;

  // Normal force and friction torque for w_rel=0
  fn = fn_max*f_normalized;
  free = fn <= 0;
  tau0 = mu0*cgeo*fn;
  tau0_max = peak*tau0;

  // Friction torque
  table_signs =
    if     startForward         then { 1, 1}
    elseif startBackward        then { 1,-1}
    elseif pre(mode) == Forward then { 1, 1}
    else                             {-1,-1};
  mu = table_signs[2]*(
    if     smoothness == Smoothness.ConstantSegments then getTable1DValueNoDer(tableID, 1, table_signs[1]*w_rel)
    elseif smoothness == Smoothness.LinearSegments   then getTable1DValueNoDer2(tableID, 1, table_signs[1]*w_rel)
    else                                                  getTable1DValue(tableID, 1, table_signs[1]*w_rel));
  tau = if locked then sa*unitTorque elseif free then 0 else mu*cgeo*fn;

  lossPower = tau*w_relfric;
  annotation (Icon(
      coordinateSystem(preserveAspectRatio=true,
        extent={{-100,-100},{100,100}}),
        graphics={
      Text(extent={{-150,-110},{150,-70}},
        textString="%name",
        textColor={0,0,255}),
      Line(visible=useHeatPort,
        points={{-100,-100},{-100,-40},{0,-40}},
        color={191,0,0},
        pattern=LinePattern.Dot)}), Documentation(info="<html>
<p>
This component models a <strong>clutch</strong>, i.e., a component with
two flanges where friction is present between the two flanges
and these flanges are pressed together via a normal force.
The normal force fn has to be provided as input signal f_normalized in a normalized form
(0 &le; f_normalized &le; 1),
fn = fn_max*f_normalized, where fn_max has to be provided as parameter. Friction in the
clutch is modelled in the following way:
</p>
<p>
When the relative angular velocity is not zero, the friction torque is a
function of the velocity dependent friction coefficient mu(w_rel), of
the normal force \"fn\", and of a geometry constant \"cgeo\" which takes into
account the geometry of the device and the assumptions on the friction
distributions:
</p>
<blockquote><pre>
frictional_torque = <strong>cgeo</strong> * <strong>mu</strong>(w_rel) * <strong>fn</strong>
</pre></blockquote>
<p>
   Typical values of coefficients of friction <strong>mu</strong>:
</p>
<ul>
  <li>0.2&nbsp;&hellip;&nbsp;0.4 for dry operation,</li>
  <li>0.05&nbsp;&hellip;&nbsp;0.1 when operating in oil.</li>
</ul>
<p>
   When plates are pressed together, where <strong>ri</strong> is the inner radius,
   <strong>ro</strong> is the outer radius and <strong>N</strong> is the number of friction interfaces,
   the geometry constant is calculated in the following way under the
   assumption of a uniform rate of wear at the interfaces:
</p>
<blockquote><pre>
<strong>cgeo</strong> = <strong>N</strong>*(<strong>r0</strong> + <strong>ri</strong>)/2
</pre></blockquote>
<p>
    The positive part of the friction characteristic <strong>mu</strong>(w_rel),
    w_rel >= 0, is defined via table mu_pos (first column = w_rel,
    second column = mu).
</p>
<p>
   When the relative angular velocity becomes zero, the elements
   connected by the friction element become stuck, i.e., the relative
   angle remains constant. In this phase the friction torque is
   calculated from a torque balance due to the requirement, that
   the relative acceleration shall be zero. The elements begin
   to slide when the friction torque exceeds a threshold value,
   called the maximum static friction torque, computed via:
</p>
<blockquote><pre>
frictional_torque = <strong>peak</strong> * <strong>cgeo</strong> * <strong>mu</strong>(w_rel=0) * <strong>fn</strong>   (<strong>peak</strong> >= 1)
</pre></blockquote>
<p>
This procedure is implemented in a \"clean\" way by state events and
leads to continuous/discrete systems of equations if friction elements
are dynamically coupled. The method is described in
(see also a short sketch in <a href=\"modelica://Modelica.Mechanics.Rotational.UsersGuide.ModelingOfFriction\">UsersGuide.ModelingOfFriction</a>):
</p>
<dl>
<dt>Otter M., Elmqvist H., and Mattsson S.E. (1999):</dt>
<dd><strong>Hybrid Modeling in Modelica based on the Synchronous
    Data Flow Principle</strong>. CACSD'99, Aug. 22.-26, Hawaii.</dd>
</dl>
<p>
More precise friction models take into account the elasticity of the
material when the two elements are \"stuck\", as well as other effects,
like hysteresis. This has the advantage that the friction element can
be completely described by a differential equation without events. The
drawback is that the system becomes stiff (about 10-20 times slower
simulation) and that more material constants have to be supplied which
requires more sophisticated identification. For more details, see the
following references, especially (Armstrong and Canudas de Wit 1996):
</p>
<dl>
<dt>Armstrong B. (1991):</dt>
<dd><strong>Control of Machines with Friction</strong>. Kluwer Academic
    Press, Boston MA.<br></dd>
<dt>Armstrong B., and Canudas de Wit C. (1996):</dt>
<dd><strong>Friction Modeling and Compensation.</strong>
    The Control Handbook, edited by W.S.Levine, CRC Press,
    pp. 1369-1382.<br></dd>
<dt>Canudas de Wit C., Olsson H., &Aring;str&ouml;m K.J., and Lischinsky P. (1995):</dt>
<dd><strong>A new model for control of systems with friction.</strong>
    IEEE Transactions on Automatic Control, Vol. 40, No. 3, pp. 419-425.</dd>
</dl>

<p>
See also the discussion
<a href=\"modelica://Modelica.Mechanics.Rotational.UsersGuide.StateSelection\">State Selection</a>
in the User's Guide of the Rotational library.
</p>
</html>"));
end Clutch;
