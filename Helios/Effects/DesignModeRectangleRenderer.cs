using System.Windows.Media;

namespace GadrocsWorkshop.Helios.Effects
{
    class DesignModeRectangleRenderer : Controls.RectangleDecorationRenderer
    {
        protected override void OnRender(DrawingContext drawingContext)
        {
            // XXX change this to new flag that indicates profile editor, so we render in the toolbox also
            if ((Visual == null) || (!Visual.DesignMode))
            {
                return;
            }
            base.OnRender(drawingContext);
        }
    }
}
