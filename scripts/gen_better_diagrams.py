#!/usr/bin/env python3
"""
生成更标准、更准确的生物教学示意图
参考人教版教材插图风格
"""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as patches
from matplotlib.patches import FancyBboxPatch, Circle, Ellipse, Arc, FancyArrow, Wedge
import numpy as np
import os

output_dir = '/tmp/biology_diagrams_v2'
os.makedirs(output_dir, exist_ok=True)

# 通用样式设置
plt.rcParams['font.family'] = ['DejaVu Sans', 'Arial']
plt.rcParams['axes.unicode_minus'] = False

def draw_plant_cell():
    """植物细胞 - 参照人教版教材风格"""
    fig, ax = plt.subplots(figsize=(7, 6))
    ax.set_xlim(0, 12)
    ax.set_ylim(0, 10)
    ax.set_aspect('equal')
    ax.axis('off')
    ax.set_title('植物细胞结构示意图', fontsize=14, fontweight='bold', pad=15)

    # 细胞壁（方形，圆角）
    cell_wall = FancyBboxPatch((1, 1.5), 8, 7, boxstyle="round,pad=0.15",
                                fill=True, facecolor='#E8F5E9', edgecolor='#1B5E20', linewidth=2.5)
    ax.add_patch(cell_wall)

    # 细胞核（椭圆形，偏心）
    nucleus = Ellipse((8, 6.5), 2.5, 2, fill=True, facecolor='#FFEBEE', edgecolor='#C62828', linewidth=2)
    ax.add_patch(nucleus)
    ax.text(8, 6.5, '细胞核', ha='center', va='center', fontsize=10, fontweight='bold')
    ax.text(8, 5.8, '(遗传物质)', ha='center', va='center', fontsize=8, color='#666')

    # 液泡（大，椭圆形）
    vacuole = Ellipse((5, 3), 4, 2.5, fill=True, facecolor='#E1BEE7', edgecolor='#7B1FA2', linewidth=1.5, alpha=0.6)
    ax.add_patch(vacuole)
    ax.text(5, 3, '液泡', ha='center', va='center', fontsize=10, fontweight='bold')

    # 叶绿体（2-3个，椭圆形）
    chloro1 = Ellipse((3, 7), 1.2, 0.6, fill=True, facecolor='#4CAF50', edgecolor='#1B5E20', linewidth=1.5)
    chloro2 = Ellipse((4.5, 7.5), 1.2, 0.6, fill=True, facecolor='#4CAF50', edgecolor='#1B5E20', linewidth=1.5)
    chloro3 = Ellipse((3.5, 5.5), 1.2, 0.6, fill=True, facecolor='#4CAF50', edgecolor='#1B5E20', linewidth=1.5)
    ax.add_patch(chloro1)
    ax.add_patch(chloro2)
    ax.add_patch(chloro3)
    ax.text(3, 8, '叶绿体', ha='center', va='center', fontsize=9, color='#1B5E20', fontweight='bold')

    # 线粒体（小，椭圆形）
    mito = Ellipse((7, 4), 1, 0.5, angle=45, fill=True, facecolor='#FFAB91', edgecolor='#E64A19', linewidth=1)
    ax.add_patch(mito)
    ax.text(7.8, 3.3, '线粒体', ha='center', va='center', fontsize=8, color='#E64A19')

    # 细胞质（背景）
    ax.text(4, 5, '细胞质', ha='center', va='center', fontsize=10, color='#555')

    # 标注线
    # 细胞壁标注
    ax.annotate('细胞壁', xy=(1.5, 5), xytext=(0.3, 5),
                fontsize=9, ha='left',
                arrowprops=dict(arrowstyle='->', color='#1B5E20', lw=1.5))

    # 图例说明
    ax.text(1, 0.5, '植物细胞有细胞壁、叶绿体、液泡、细胞核等结构',
            fontsize=9, color='#333', style='italic')

    plt.tight_layout()
    path = f'{output_dir}/plant_cell.png'
    plt.savefig(path, dpi=150, bbox_inches='tight', facecolor='white')
    plt.close()
    print(f'已生成：{path}')

def draw_animal_cell():
    """动物细胞 - 参照人教版教材风格"""
    fig, ax = plt.subplots(figsize=(7, 6))
    ax.set_xlim(0, 12)
    ax.set_ylim(0, 10)
    ax.set_aspect('equal')
    ax.axis('off')
    ax.set_title('动物细胞结构示意图', fontsize=14, fontweight='bold', pad=15)

    # 细胞膜（椭圆形，不规则）
    cell = Ellipse((6, 5), 8, 6, fill=True, facecolor='#E3F2FD', edgecolor='#1565C0', linewidth=2.5)
    ax.add_patch(cell)

    # 细胞核（椭圆形，偏心）
    nucleus = Ellipse((8, 6.5), 2.5, 2, fill=True, facecolor='#FFEBEE', edgecolor='#C62828', linewidth=2)
    ax.add_patch(nucleus)
    ax.text(8, 6.5, '细胞核', ha='center', va='center', fontsize=10, fontweight='bold')

    # 线粒体（2-3个）
    mito1 = Ellipse((4, 5.5), 1.2, 0.6, angle=30, fill=True, facecolor='#FFAB91', edgecolor='#E64A19', linewidth=1.5)
    mito2 = Ellipse((5, 3.5), 1.2, 0.6, angle=-20, fill=True, facecolor='#FFAB91', edgecolor='#E64A19', linewidth=1.5)
    mito3 = Ellipse((7, 4), 1.2, 0.6, angle=60, fill=True, facecolor='#FFAB91', edgecolor='#E64A19', linewidth=1.5)
    ax.add_patch(mito1)
    ax.add_patch(mito2)
    ax.add_patch(mito3)
    ax.text(3.5, 4.5, '线粒体', ha='center', va='center', fontsize=9, color='#E64A19', fontweight='bold')

    # 高尔基体（小囊状）
    golgi = patches.Arc((6, 7), 1.5, 0.8, angle=0, theta1=0, theta2=180, color='#FF6F00', linewidth=1.5)
    ax.add_patch(golgi)
    ax.text(7.2, 7.2, '高尔基体', ha='left', va='center', fontsize=8, color='#FF6F00')

    # 细胞质
    ax.text(5, 4.5, '细胞质', ha='center', va='center', fontsize=10, color='#555')

    # 标注
    ax.annotate('细胞膜', xy=(2.5, 5), xytext=(0.5, 5),
                fontsize=9, ha='left',
                arrowprops=dict(arrowstyle='->', color='#1565C0', lw=1.5))

    # 图例说明
    ax.text(1, 0.5, '动物细胞没有细胞壁，有细胞膜、细胞质、细胞核等结构',
            fontsize=9, color='#333', style='italic')

    plt.tight_layout()
    path = f'{output_dir}/animal_cell.png'
    plt.savefig(path, dpi=150, bbox_inches='tight', facecolor='white')
    plt.close()
    print(f'已生成：{path}')

def draw_eye():
    """眼球结构 - 水平切面图，参照教材"""
    fig, ax = plt.subplots(figsize=(9, 5))
    ax.set_xlim(0, 14)
    ax.set_ylim(0, 8)
    ax.set_aspect('equal')
    ax.axis('off')
    ax.set_title('眼球结构示意图（水平切面）', fontsize=14, fontweight='bold', pad=15)

    # 眼球轮廓
    outer = Ellipse((7, 4), 10, 6, fill=False, edgecolor='black', linewidth=2.5)
    ax.add_patch(outer)

    # 角膜（前方透明部分）
    ax.add_patch(Wedge((1.5, 4), 1.5, 70, 110, fill=True, facecolor='#FFECB3', edgecolor='#FF8F00', linewidth=1.5, alpha=0.7))

    # 虹膜（有色环）
    iris = Ellipse((3.5, 4), 1.2, 2.5, fill=True, facecolor='#5D4037', edgecolor='#3E2723', linewidth=1.5)
    ax.add_patch(iris)

    # 瞳孔（黑孔）
    pupil = Circle((3.5, 4), 0.6, fill=True, facecolor='black')
    ax.add_patch(pupil)

    # 晶状体（双凸透镜）
    lens = Ellipse((5.5, 4), 1.5, 3, fill=True, facecolor='#FFF9C4', edgecolor='#FBC02D', linewidth=2, alpha=0.8)
    ax.add_patch(lens)

    # 玻璃体（填充眼球内部）
    vitreous = Ellipse((8, 4), 5, 4.5, fill=True, facecolor='#E3F2FD', edgecolor='none', alpha=0.3)
    ax.add_patch(vitreous)

    # 视网膜（后方弧线）
    retina = Arc((12, 4), 4, 5, angle=0, theta1=60, theta2=120, color='#D32F2F', linewidth=2.5)
    ax.add_patch(retina)

    # 脉络膜（视网膜外层）
    choroid = Arc((12, 4), 4.5, 5.5, angle=0, theta1=55, theta2=125, color='#4A148C', linewidth=1.5)
    ax.add_patch(choroid)

    # 巩膜（外层）
    sclera = Arc((12, 4), 5, 6, angle=0, theta1=50, theta2=130, color='#BDBDBD', linewidth=1)
    ax.add_patch(sclera)

    # 视神经
    ax.annotate('', xy=(13.5, 4), xytext=(12, 4),
                arrowprops=dict(arrowstyle='->', color='#FDD835', lw=3))
    ax.text(13.3, 4.5, '视神经', fontsize=9, ha='left', fontweight='bold')

    # 标注
    ax.text(1.5, 6.5, '①角膜', fontsize=10, ha='center', fontweight='bold', color='#FF8F00')
    ax.text(3.5, 7, '②虹膜', fontsize=10, ha='center', fontweight='bold', color='#5D4037')
    ax.text(5.5, 7.2, '③晶状体', fontsize=10, ha='center', fontweight='bold', color='#FBC02D')
    ax.text(10, 7.5, '④视网膜', fontsize=10, ha='center', fontweight='bold', color='#D32F2F')

    # 功能说明
    ax.text(0.5, 0.5, '光线→角膜→瞳孔→晶状体（折射）→视网膜（成像）→视神经→大脑',
            fontsize=9, color='#333', style='italic')

    plt.tight_layout()
    path = f'{output_dir}/eye.png'
    plt.savefig(path, dpi=150, bbox_inches='tight', facecolor='white')
    plt.close()
    print(f'已生成：{path}')

def draw_heart():
    """心脏结构 - 前面观，参照教材"""
    fig, ax = plt.subplots(figsize=(8, 7))
    ax.set_xlim(0, 12)
    ax.set_ylim(0, 10)
    ax.set_aspect('equal')
    ax.axis('off')
    ax.set_title('心脏结构示意图（前面观）', fontsize=14, fontweight='bold', pad=15)

    # 左心房
    la = FancyBboxPatch((6.5, 6), 4, 2.5, boxstyle="round,pad=0.1",
                        fill=True, facecolor='#FFCDD2', edgecolor='#C62828', linewidth=2.5)
    ax.add_patch(la)
    ax.text(8.5, 7.25, '②左心房', ha='center', va='center', fontsize=11, fontweight='bold')

    # 右心房
    ra = FancyBboxPatch((1.5, 6), 4, 2.5, boxstyle="round,pad=0.1",
                        fill=True, facecolor='#BBDEFB', edgecolor='#1565C0', linewidth=2.5)
    ax.add_patch(ra)
    ax.text(3.5, 7.25, '①右心房', ha='center', va='center', fontsize=11, fontweight='bold')

    # 左心室（壁最厚）
    lv = FancyBboxPatch((6.5, 1.5), 4, 4, boxstyle="round,pad=0.1",
                        fill=True, facecolor='#EF9A9A', edgecolor='#C62828', linewidth=3)
    ax.add_patch(lv)
    ax.text(8.5, 3.5, '④左心室', ha='center', va='center', fontsize=11, fontweight='bold')
    ax.text(8.5, 2.3, '(壁最厚)', ha='center', va='center', fontsize=9, color='#C62828')

    # 右心室
    rv = FancyBboxPatch((1.5, 2), 4, 3.5, boxstyle="round,pad=0.1",
                        fill=True, facecolor='#90CAF9', edgecolor='#1565C0', linewidth=2.5)
    ax.add_patch(rv)
    ax.text(3.5, 4, '③右心室', ha='center', va='center', fontsize=11, fontweight='bold')

    # 主动脉
    ax.annotate('', xy=(10.5, 7), xytext=(9.5, 6.5),
                arrowprops=dict(arrowstyle='->', color='#C62828', lw=3))
    ax.text(10.8, 7.2, '主动脉', fontsize=9, ha='left', fontweight='bold', color='#C62828')

    # 肺动脉
    ax.annotate('', xy=(0.5, 7), xytext=(1.5, 6.5),
                arrowprops=dict(arrowstyle='->', color='#1565C0', lw=3))
    ax.text(0.3, 7.5, '肺动脉', fontsize=9, ha='left', fontweight='bold', color='#1565C0')

    # 肺静脉
    ax.annotate('', xy=(6.5, 7.25), xytext=(5.5, 7.25),
                arrowprops=dict(arrowstyle='->', color='#C62828', lw=2))
    ax.text(5.3, 7.8, '肺静脉', fontsize=8, ha='right', color='#C62828')

    # 上腔静脉
    ax.text(1.5, 9, '上腔静脉', fontsize=8, ha='center', color='#1565C0')
    ax.annotate('', xy=(2, 8.5), xytext=(2, 8.5), arrowprops=dict(arrowstyle='->', color='#1565C0', lw=2))

    # 房室瓣标注
    ax.text(5, 4.5, '⑤\n房室瓣', fontsize=8, ha='center', va='center', color='#6A1B9A', fontweight='bold')

    # 主动脉和肺动脉标注
    ax.text(10.5, 5.5, '⑥动脉瓣', fontsize=8, ha='left', color='#6A1B9A')

    plt.tight_layout()
    path = f'{output_dir}/heart.png'
    plt.savefig(path, dpi=150, bbox_inches='tight', facecolor='white')
    plt.close()
    print(f'已生成：{path}')

def draw_reflex_arc():
    """反射弧结构 - 参照教材"""
    fig, ax = plt.subplots(figsize=(10, 5))
    ax.set_xlim(0, 14)
    ax.set_ylim(0, 8)
    ax.set_aspect('equal')
    ax.axis('off')
    ax.set_title('反射弧结构示意图', fontsize=14, fontweight='bold', pad=15)

    # 感受器（皮肤）
    skin = FancyBboxPatch((0.3, 2.5), 1.8, 2, boxstyle="round,pad=0.1",
                          fill=True, facecolor='#FFCCBC', edgecolor='#BF360C', linewidth=2)
    ax.add_patch(skin)
    ax.text(1.2, 3.5, '感受器\n(皮肤)', ha='center', va='center', fontsize=9, fontweight='bold')

    # 传入神经
    ax.annotate('', xy=(3.5, 4), xytext=(2.1, 4),
                arrowprops=dict(arrowstyle='->', color='#E53935', lw=3))
    ax.text(2.8, 4.7, '①传入神经', fontsize=9, ha='center', color='#E53935', fontweight='bold')

    # 神经中枢（脊髓）
    spinal = FancyBboxPatch((3.5, 1), 3, 5, boxstyle="round,pad=0.1",
                           fill=True, facecolor='#E1BEE7', edgecolor='#7B1FA2', linewidth=2)
    ax.add_patch(spinal)
    ax.text(5, 3.5, '神经中枢\n(脊髓)', ha='center', va='center', fontsize=10, fontweight='bold')

    # 标注脊髓
    ax.text(5, 5.5, '灰质', ha='center', va='center', fontsize=8, color='#7B1FA2')
    ax.text(5, 1.8, '白质', ha='center', va='center', fontsize=8, color='#7B1FA2')

    # 传出神经
    ax.annotate('', xy=(7.8, 4), xytext=(6.5, 4),
                arrowprops=dict(arrowstyle='->', color='#1E88E5', lw=3))
    ax.text(7.2, 4.7, '③传出神经', fontsize=9, ha='center', color='#1E88E5', fontweight='bold')

    # 效应器（肌肉）
    muscle = FancyBboxPatch((7.8, 2.5), 1.8, 2, boxstyle="round,pad=0.1",
                           fill=True, facecolor='#A5D6A7', edgecolor='#2E7D32', linewidth=2)
    ax.add_patch(muscle)
    ax.text(8.7, 3.5, '效应器\n(肌肉)', ha='center', va='center', fontsize=9, fontweight='bold')

    # 箭头表示神经冲动方向
    ax.text(4.5, 2, '神经冲动传导方向：感受器→传入神经→神经中枢→传出神经→效应器',
            fontsize=9, color='#333', style='italic', ha='center')

    # 标注
    ax.text(1.2, 5, '①', fontsize=10, ha='center', color='#E53935', fontweight='bold')
    ax.text(5, 6.3, '②', fontsize=10, ha='center', color='#7B1FA2', fontweight='bold')
    ax.text(8.7, 5, '④', fontsize=10, ha='center', color='#2E7D32', fontweight='bold')

    plt.tight_layout()
    path = f'{output_dir}/reflex_arc.png'
    plt.savefig(path, dpi=150, bbox_inches='tight', facecolor='white')
    plt.close()
    print(f'已生成：{path}')

def draw_leaf():
    """叶片结构 - 横切面，参照教材"""
    fig, ax = plt.subplots(figsize=(8, 6))
    ax.set_xlim(0, 12)
    ax.set_ylim(0, 10)
    ax.set_aspect('equal')
    ax.axis('off')
    ax.set_title('叶片结构示意图（横切面）', fontsize=14, fontweight='bold', pad=15)

    # 上表皮
    upper_e = FancyBboxPatch((1, 7.5), 10, 1, fill=True, facecolor='#FFF9C4', edgecolor='#F57F17', linewidth=2)
    ax.add_patch(upper_e)
    ax.text(6, 8, '①上表皮（角质层）', ha='center', va='center', fontsize=9, fontweight='bold')

    # 栅栏组织
    palisade = FancyBboxPatch((1, 4.5), 10, 3, fill=True, facecolor='#C8E6C9', edgecolor='#388E3C', linewidth=2)
    ax.add_patch(palisade)
    ax.text(6, 6, '②栅栏组织', ha='center', va='center', fontsize=10, fontweight='bold')
    ax.text(6, 5.3, '(细胞排列紧密，含叶绿体较多)', ha='center', va='center', fontsize=8, color='#666')

    # 海绵组织
    spongy = FancyBboxPatch((1, 2), 10, 2.5, fill=True, facecolor='#DCEDC8', edgecolor='#689F38', linewidth=2)
    ax.add_patch(spongy)
    ax.text(6, 3.25, '③海绵组织', ha='center', va='center', fontsize=10, fontweight='bold')
    ax.text(6, 2.5, '(细胞排列疏松，间隙大)', ha='center', va='center', fontsize=8, color='#666')

    # 下表皮
    lower_e = FancyBboxPatch((1, 0.8), 10, 1.2, fill=True, facecolor='#FFF9C4', edgecolor='#F57F17', linewidth=2)
    ax.add_patch(lower_e)
    ax.text(6, 1.4, '④下表皮', ha='center', va='center', fontsize=9, fontweight='bold')

    # 气孔（保卫细胞）
    ax.add_patch(Circle((5, 0.8), 0.4, fill=True, facecolor='#AED581', edgecolor='#33691E', linewidth=1.5))
    ax.add_patch(Circle((6, 0.8), 0.4, fill=True, facecolor='#AED581', edgecolor='#33691E', linewidth=1.5))
    ax.text(5.5, 0.3, '⑥气孔', ha='center', va='center', fontsize=9, fontweight='bold', color='#33691E')
    ax.text(5.5, -0.3, '(保卫细胞围成)', ha='center', va='center', fontsize=7, color='#666')

    # 叶脉（主脉）
    ax.plot([6, 6], [1, 7.5], color='#795548', linewidth=4)
    ax.text(6.8, 4, '④叶脉', ha='left', va='center', fontsize=9, fontweight='bold', color='#795548')
    ax.text(6.8, 3.3, '(导管：运输水和无机盐)', ha='left', va='center', fontsize=7, color='#795548')
    ax.text(6.8, 2.8, '(筛管：运输有机物)', ha='left', va='center', fontsize=7, color='#795548')

    plt.tight_layout()
    path = f'{output_dir}/leaf.png'
    plt.savefig(path, dpi=150, bbox_inches='tight', facecolor='white')
    plt.close()
    print(f'已生成：{path}')

def draw_food_web():
    """生态系统食物网 - 参照教材"""
    fig, ax = plt.subplots(figsize=(9, 7))
    ax.set_xlim(0, 12)
    ax.set_ylim(0, 10)
    ax.set_aspect('equal')
    ax.axis('off')
    ax.set_title('生态系统食物网示意图', fontsize=14, fontweight='bold', pad=15)

    # 草（生产者）
    grass = FancyBboxPatch((5, 0.5), 2, 1, boxstyle="round,pad=0.1",
                           fill=True, facecolor='#4CAF50', edgecolor='#1B5E20', linewidth=2)
    ax.add_patch(grass)
    ax.text(6, 1, '草', ha='center', va='center', fontsize=12, fontweight='bold', color='white')
    ax.text(6, 0.2, '(生产者)', ha='center', va='center', fontsize=8, color='#1B5E20')

    # 兔（初级消费者）
    rabbit = FancyBboxPatch((1.5, 3), 1.8, 1, boxstyle="round,pad=0.1",
                            fill=True, facecolor='#FF8A65', edgecolor='#E64A19', linewidth=2)
    ax.add_patch(rabbit)
    ax.text(2.4, 3.5, '兔', ha='center', va='center', fontsize=11, fontweight='bold', color='white')

    # 蝗虫（初级消费者）
    locust = FancyBboxPatch((8.5, 3), 1.8, 1, boxstyle="round,pad=0.1",
                            fill=True, facecolor='#FF8A65', edgecolor='#E64A19', linewidth=2)
    ax.add_patch(locust)
    ax.text(9.4, 3.5, '蝗虫', ha='center', va='center', fontsize=11, fontweight='bold', color='white')

    # 青蛙（次级消费者）
    frog = FancyBboxPatch((5, 5), 2, 1.2, boxstyle="round,pad=0.1",
                          fill=True, facecolor='#EF5350', edgecolor='#C62828', linewidth=2)
    ax.add_patch(frog)
    ax.text(6, 5.6, '青蛙', ha='center', va='center', fontsize=11, fontweight='bold', color='white')

    # 蛇（三级消费者）
    snake = FancyBboxPatch((9.5, 6), 2, 1, boxstyle="round,pad=0.1",
                           fill=True, facecolor='#9C27B0', edgecolor='#6A1B9A', linewidth=2)
    ax.add_patch(snake)
    ax.text(10.5, 6.5, '蛇', ha='center', va='center', fontsize=11, fontweight='bold', color='white')

    # 鹰（顶级消费者）
    eagle = FancyBboxPatch((1, 7), 2, 1, boxstyle="round,pad=0.1",
                           fill=True, facecolor='#5C6BC0', edgecolor='#303F9F', linewidth=2)
    ax.add_patch(eagle)
    ax.text(2, 7.5, '鹰', ha='center', va='center', fontsize=11, fontweight='bold', color='white')

    # 分解者
    decomposer = FancyBboxPatch((9.5, 0.5), 2, 1, boxstyle="round,pad=0.1",
                                fill=True, facecolor='#9E9E9E', edgecolor='#616161', linewidth=2)
    ax.add_patch(decomposer)
    ax.text(10.5, 1, '分解者', ha='center', va='center', fontsize=10, fontweight='bold', color='white')

    # 箭头 - 草到兔
    ax.annotate('', xy=(2.7, 3.2), xytext=(5.5, 1.5),
                arrowprops=dict(arrowstyle='->', color='#4CAF50', lw=2))

    # 箭头 - 草到蝗虫
    ax.annotate('', xy=(8.7, 3.2), xytext=(6.5, 1.5),
                arrowprops=dict(arrowstyle='->', color='#4CAF50', lw=2))

    # 箭头 - 蝗虫到青蛙
    ax.annotate('', xy=(6.2, 5.2), xytext=(8.7, 3.2),
                arrowprops=dict(arrowstyle='->', color='#4CAF50', lw=2))

    # 箭头 - 兔到蛇
    ax.annotate('', xy=(9.7, 6.2), xytext=(3.3, 3.2),
                arrowprops=dict(arrowstyle='->', color='#4CAF50', lw=2))

    # 箭头 - 青蛙到蛇
    ax.annotate('', xy=(9.7, 6.2), xytext=(6.5, 5.2),
                arrowprops=dict(arrowstyle='->', color='#4CAF50', lw=2))

    # 箭头 - 蛇到鹰
    ax.annotate('', xy=(2.8, 7.2), xytext=(9.5, 6.2),
                arrowprops=dict(arrowstyle='->', color='#4CAF50', lw=2))

    # 图例
    ax.text(0.5, 9, '图例：', fontsize=10, fontweight='bold')
    ax.text(0.5, 8.3, '绿色箭头：能量流动方向', fontsize=9, color='#4CAF50')
    ax.text(0.5, 7.6, '生产者：草（绿色植物）', fontsize=9)
    ax.text(0.5, 7, '消费者：兔、蝗虫、青蛙、蛇、鹰', fontsize=9)
    ax.text(0.5, 6.3, '分解者：细菌、真菌等', fontsize=9)

    plt.tight_layout()
    path = f'{output_dir}/food_web.png'
    plt.savefig(path, dpi=150, bbox_inches='tight', facecolor='white')
    plt.close()
    print(f'已生成：{path}')

def draw_seed():
    """种子结构 - 菜豆和玉米对比，参照教材"""
    fig, axes = plt.subplots(1, 2, figsize=(10, 6))

    # 菜豆种子
    ax1 = axes[0]
    ax1.set_xlim(0, 8)
    ax1.set_ylim(0, 10)
    ax1.set_aspect('equal')
    ax1.axis('off')
    ax1.set_title('菜豆种子结构', fontsize=12, fontweight='bold')

    # 种皮
    seed_coat = Ellipse((4, 5), 5, 7, fill=True, facecolor='#D7CCC8', edgecolor='#795548', linewidth=3)
    ax1.add_patch(seed_coat)

    # 胚芽
    ax1.add_patch(FancyBboxPatch((3, 7.5), 1.5, 1, fill=True, facecolor='#A5D6A7', edgecolor='#388E3C', linewidth=1.5))
    ax1.text(3.75, 8, '①胚芽', ha='center', va='center', fontsize=9, fontweight='bold')

    # 胚根
    ax1.add_patch(FancyBboxPatch((3, 1.5), 1.5, 1, fill=True, facecolor='#A5D6A7', edgecolor='#388E3C', linewidth=1.5))
    ax1.text(3.75, 2, '③胚根', ha='center', va='center', fontsize=9, fontweight='bold')

    # 子叶（两片，肥厚）
    ax1.add_patch(Ellipse((2.5, 5), 0.8, 3.5, fill=True, facecolor='#FFF59D', edgecolor='#FBC02D', linewidth=1.5))
    ax1.add_patch(Ellipse((5.5, 5), 0.8, 3.5, fill=True, facecolor='#FFF59D', edgecolor='#FBC02D', linewidth=1.5))
    ax1.text(1.5, 5, '④子叶\n(2片)', ha='center', va='center', fontsize=9, fontweight='bold')
    ax1.text(6.5, 5, '储藏\n营养', ha='center', va='center', fontsize=8, color='#FBC02D')

    # 玉米种子
    ax2 = axes[1]
    ax2.set_xlim(0, 8)
    ax2.set_ylim(0, 10)
    ax2.set_aspect('equal')
    ax2.axis('off')
    ax2.set_title('玉米种子结构', fontsize=12, fontweight='bold')

    # 果皮+种皮
    fruit_coat = Ellipse((4, 5), 5, 7, fill=True, facecolor='#D7CCC8', edgecolor='#795548', linewidth=3)
    ax2.add_patch(fruit_coat)

    # 胚乳（大部分）
    endosperm = Ellipse((4.5, 5), 3.5, 5, fill=True, facecolor='#FFF9C4', edgecolor='#FBC02D', linewidth=2)
    ax2.add_patch(endosperm)
    ax2.text(4.5, 5, '⑤胚乳\n(储藏营养)', ha='center', va='center', fontsize=9, fontweight='bold')

    # 胚（较小）
    ax2.add_patch(FancyBboxPatch((1.5, 3), 1.5, 3.5, fill=True, facecolor='#A5D6A7', edgecolor='#388E3C', linewidth=1.5))
    ax2.text(2.25, 5, '胚', ha='center', va='center', fontsize=9, fontweight='bold')

    # 子叶（1片，贴在胚芽上）
    ax2.add_patch(Ellipse((2.8, 4.5), 0.4, 1.5, fill=True, facecolor='#FFF59D', edgecolor='#FBC02D', linewidth=1))
    ax2.text(3.3, 4.5, '⑨子叶\n(1片)', ha='left', va='center', fontsize=7)

    plt.tight_layout()
    path = f'{output_dir}/seed.png'
    plt.savefig(path, dpi=150, bbox_inches='tight', facecolor='white')
    plt.close()
    print(f'已生成：{path}')

def draw_digestive():
    """人体消化系统 - 参照教材"""
    fig, ax = plt.subplots(figsize=(10, 8))
    ax.set_xlim(0, 14)
    ax.set_ylim(0, 12)
    ax.set_aspect('equal')
    ax.axis('off')
    ax.set_title('人体消化系统示意图', fontsize=14, fontweight='bold', pad=15)

    # 口腔
    mouth = FancyBboxPatch((1, 8), 2.5, 2, boxstyle="round,pad=0.1",
                            fill=True, facecolor='#FFAB91', edgecolor='#E64A19', linewidth=2)
    ax.add_patch(mouth)
    ax.text(2.25, 9, 'A 口腔', ha='center', va='center', fontsize=10, fontweight='bold')

    # 咽
    pharynx = FancyBboxPatch((2, 6.5), 1.5, 1.5, fill=True, facecolor='#FFAB91', edgecolor='#E64A19', linewidth=1.5)
    ax.add_patch(pharynx)
    ax.text(2.75, 7.25, 'B 咽', ha='center', va='center', fontsize=9, fontweight='bold')

    # 食道
    esophagus = FancyBboxPatch((2.2, 3), 1, 3.5, fill=True, facecolor='#FFCCBC', edgecolor='#E64A19', linewidth=1.5)
    ax.add_patch(esophagus)
    ax.text(2.7, 4.75, 'C\n食道', ha='center', va='center', fontsize=8, fontweight='bold')

    # 胃
    stomach = Ellipse((5.5, 5), 2.5, 3.5, fill=True, facecolor='#CE93D8', edgecolor='#7B1FA2', linewidth=2)
    ax.add_patch(stomach)
    ax.text(5.5, 5, 'D 胃', ha='center', va='center', fontsize=10, fontweight='bold')

    # 小肠（最长的消化器官）
    small_intestine = FancyBboxPatch((7.5, 2.5), 3, 5.5, boxstyle="round,pad=0.1",
                                    fill=True, facecolor='#FFCDD2', edgecolor='#C62828', linewidth=2)
    ax.add_patch(small_intestine)
    ax.text(9, 5.25, 'E 小肠', ha='center', va='center', fontsize=10, fontweight='bold')
    ax.text(9, 3.5, '(消化和吸收', ha='center', va='center', fontsize=8, color='#666')
    ax.text(9, 3, '的主要场所)', ha='center', va='center', fontsize=8, color='#666')

    # 大肠
    large_intestine = FancyBboxPatch((10.5, 3.5), 2, 5, boxstyle="round,pad=0.1",
                                    fill=True, facecolor='#C8E6C9', edgecolor='#388E3C', linewidth=2)
    ax.add_patch(large_intestine)
    ax.text(11.5, 6, 'F 大肠', ha='center', va='center', fontsize=10, fontweight='bold')

    # 肝脏
    liver = FancyBboxPatch((4, 9), 3, 2, boxstyle="round,pad=0.1",
                            fill=True, facecolor='#A1887F', edgecolor='#5D4037', linewidth=2)
    ax.add_patch(liver)
    ax.text(5.5, 10, 'G 肝脏', ha='center', va='center', fontsize=10, fontweight='bold', color='white')

    # 胰腺
    pancreas = FancyBboxPatch((5.5, 1.5), 2.5, 1.5, boxstyle="round,pad=0.1",
                               fill=True, facecolor='#FFE082', edgecolor='#F9A825', linewidth=2)
    ax.add_patch(pancreas)
    ax.text(6.75, 2.25, 'H 胰腺', ha='center', va='center', fontsize=9, fontweight='bold')

    # 阑尾
    appendix = FancyBboxPatch((12, 1.5), 1, 1.5, boxstyle="round,pad=0.1",
                              fill=True, facecolor='#BCAAA4', edgecolor='#6D4C41', linewidth=1.5)
    ax.add_patch(appendix)
    ax.text(12.5, 2.25, 'I 阑尾', ha='center', va='center', fontsize=8, fontweight='bold')

    # 标注线 - 口腔到食道
    ax.annotate('', xy=(2.5, 6.5), xytext=(2.5, 8),
                arrowprops=dict(arrowstyle='->', color='#E64A19', lw=1.5))

    plt.tight_layout()
    path = f'{output_dir}/digestive.png'
    plt.savefig(path, dpi=150, bbox_inches='tight', facecolor='white')
    plt.close()
    print(f'已生成：{path}')

# 生成所有图片
print("开始生成改进版生物教学示意图...")
draw_plant_cell()
draw_animal_cell()
draw_eye()
draw_heart()
draw_reflex_arc()
draw_leaf()
draw_food_web()
draw_seed()
draw_digestive()

print(f"\n所有图片已保存到：{output_dir}")
print("共生成9张改进版图片")
