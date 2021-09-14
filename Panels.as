namespace ZUtil
{
	class PluginPanel
	{
		vec2 m_pos;
		vec2 m_size;

		void OnSettingsChanged() {}
		void Render() {}
		void Update(float dt) {}
	}

	class NvgPanel : PluginPanel
	{
		void InternalRender()
		{
			vec2 screenSize = vec2(Draw::GetWidth(), Draw::GetHeight());
			vec2 pos = m_pos * (screenSize - m_size);
			nvg::Translate(pos.x, pos.y);
			Render();
			nvg::ResetTransform();
		}
	}

	class UiPanel : PluginPanel
	{

	}
}
