shader_type spatial;
uniform vec4 Color : source_color = vec4(0.000000, 0.000000, 0.000000, 1.000000);
uniform float speed = 10.f;
uniform float change = 2.f;

void vertex() {
	VERTEX.y += cos(VERTEX.x * change * sin(TIME * speed)) * sin(VERTEX.z * change * sin(TIME * speed));
	VERTEX.x += cos(TIME * speed) * 0.6;
	VERTEX.z -= cos(VERTEX.x * change * sin(-TIME * speed)) * sin(VERTEX.x * change * sin(-TIME * speed));
}

void fragment() {
	ALBEDO = vec3(Color.xyz); 
}

void light() {
	 DIFFUSE_LIGHT = vec3(Color.xyz);
}
