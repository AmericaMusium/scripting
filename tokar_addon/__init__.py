bl_info = {
    "name": "Токарная обработка",
    "author": "Your Name",
    "version": (1, 0),
    "blender": (4, 1, 0),
    "location": "View3D > Sidebar > Токарная обработка",
    "description": "Плагин для токарной обработки",
    "warning": "",
    "doc_url": "",
    "category": "Manufacturing",
}

import bpy
from bpy.props import FloatProperty, EnumProperty, BoolProperty, StringProperty
from bpy.types import Operator, Panel, PropertyGroup
import math
from mathutils import Vector
from . import gcode_generator

# Класс для хранения настроек инструмента
class TokarToolSettings(PropertyGroup):
    tool_diameter: FloatProperty(
        name="Диаметр инструмента",
        description="Диаметр режущего инструмента в мм",
        default=10.0,
        min=0.1,
        max=100.0,
        unit='LENGTH'
    )
    
    tool_length: FloatProperty(
        name="Длина инструмента",
        description="Рабочая длина инструмента в мм",
        default=50.0,
        min=1.0,
        max=500.0,
        unit='LENGTH'
    )
    
    spindle_speed: FloatProperty(
        name="Обороты шпинделя",
        description="Скорость вращения шпинделя (об/мин)",
        default=1000.0,
        min=100.0,
        max=24000.0
    )
    
    feed_rate: FloatProperty(
        name="Подача",
        description="Скорость подачи (мм/мин)",
        default=100.0,
        min=1.0,
        max=5000.0,
        unit='LENGTH'
    )

    cut_depth: FloatProperty(
        name="Глубина резания",
        description="Глубина резания за проход (мм)",
        default=1.0,
        min=0.1,
        max=10.0,
        unit='LENGTH'
    )

    gcode_filepath: StringProperty(
        name="Путь к G-коду",
        description="Путь сохранения G-кода",
        default="//gcode.nc",
        subtype='FILE_PATH'
    )

# Оператор для создания траектории обработки
class TOKAR_OT_generate_toolpath(Operator):
    bl_idname = "tokar.generate_toolpath"
    bl_label = "Создать траекторию"
    bl_description = "Создать траекторию движения инструмента"
    
    def execute(self, context):
        # Получаем активный объект
        obj = context.active_object
        if obj is None:
            self.report({'ERROR'}, "Не выбран объект для обработки")
            return {'CANCELLED'}
            
        # Получаем настройки инструмента
        settings = context.scene.tokar_settings
        
        # Создаем траекторию (упрощенная версия)
        self.generate_simple_toolpath(context, obj, settings)
        
        return {'FINISHED'}
    
    def generate_simple_toolpath(self, context, obj, settings):
        # Создаем новую кривую для траектории
        curve_data = bpy.data.curves.new(name='Toolpath', type='CURVE')
        curve_data.dimensions = '3D'
        
        # Создаем объект кривой
        curve_obj = bpy.data.objects.new('Toolpath', curve_data)
        context.scene.collection.objects.link(curve_obj)
        
        # Создаем точки траектории (простой пример)
        polyline = curve_data.splines.new('POLY')
        
        # Добавляем точки (пример простой траектории)
        points = [(0,0,0), (100,0,0), (100,10,0), (0,10,0)]
        polyline.points.add(len(points)-1)
        for i, point in enumerate(points):
            polyline.points[i].co = (point[0], point[1], point[2], 1)

# Оператор для экспорта G-кода
class TOKAR_OT_export_gcode(Operator):
    bl_idname = "tokar.export_gcode"
    bl_label = "Экспорт G-код"
    bl_description = "Экспортировать траекторию в G-код"
    
    def execute(self, context):
        obj = context.active_object
        if obj is None:
            self.report({'ERROR'}, "Не выбран объект для обработки")
            return {'CANCELLED'}
            
        settings = context.scene.tokar_settings
        
        # Создаем генератор G-кода
        generator = gcode_generator.GCodeGenerator()
        
        # Генерируем G-код
        gcode = generator.generate_turning_path(obj, settings)
        
        # Сохраняем G-код
        try:
            filepath = bpy.path.abspath(settings.gcode_filepath)
            gcode_generator.save_gcode(filepath, gcode)
            self.report({'INFO'}, f"G-код сохранен в {filepath}")
        except Exception as e:
            self.report({'ERROR'}, f"Ошибка при сохранении G-кода: {str(e)}")
            return {'CANCELLED'}
            
        return {'FINISHED'}

# Панель интерфейса
class TOKAR_PT_main_panel(Panel):
    bl_label = "Токарная обработка"
    bl_idname = "TOKAR_PT_main_panel"
    bl_space_type = 'VIEW_3D'
    bl_region_type = 'UI'
    bl_category = "Токарная обработка"
    
    def draw(self, context):
        layout = self.layout
        settings = context.scene.tokar_settings
        
        # Параметры инструмента
        box = layout.box()
        box.label(text="Параметры инструмента:")
        box.prop(settings, "tool_diameter")
        box.prop(settings, "tool_length")
        
        # Параметры обработки
        box = layout.box()
        box.label(text="Параметры обработки:")
        box.prop(settings, "spindle_speed")
        box.prop(settings, "feed_rate")
        box.prop(settings, "cut_depth")
        
        # Путь к файлу G-кода
        layout.prop(settings, "gcode_filepath")
        
        # Кнопки
        layout.operator("tokar.generate_toolpath")
        layout.operator("tokar.export_gcode")

# Список классов для регистрации
classes = (
    TokarToolSettings,
    TOKAR_OT_generate_toolpath,
    TOKAR_OT_export_gcode,
    TOKAR_PT_main_panel,
)

def register():
    for cls in classes:
        bpy.utils.register_class(cls)
    bpy.types.Scene.tokar_settings = bpy.props.PointerProperty(type=TokarToolSettings)

def unregister():
    for cls in reversed(classes):
        bpy.utils.unregister_class(cls)
    del bpy.types.Scene.tokar_settings

if __name__ == "__main__":
    register() 