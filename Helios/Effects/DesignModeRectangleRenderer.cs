using System.Windows.Media;

namespace GadrocsWorkshop.Helios.Effects
{
    class DesignModeRectangleRenderer : Controls.RectangleDecorationRenderer
    {
        protected override void OnRender(DrawingContext drawingContext)
        {
            if ((Visual == null) || (!Visual.DesignMode))
            {
                return;
            }
            base.OnRender(drawingContext);
        }
    }
}
