"""
Funciones utilitarias reutilizables para el proyecto.
"""

import os
from pathlib import Path

from dotenv import load_dotenv

# Cargar variables de entorno automáticamente
load_dotenv()


def get_project_root() -> Path:
    """Retorna la ruta raíz del proyecto."""
    return Path(__file__).parent.parent


def get_data_path(subfolder: str = "raw") -> Path:
    """
    Retorna la ruta a una subcarpeta de data/.

    Args:
        subfolder: 'raw', 'processed' o 'external'

    Returns:
        Path a la carpeta solicitada
    """
    path = get_project_root() / "data" / subfolder
    path.mkdir(parents=True, exist_ok=True)
    return path


def get_outputs_path(subfolder: str = "figures") -> Path:
    """
    Retorna la ruta a una subcarpeta de outputs/.

    Args:
        subfolder: 'figures' o 'models'

    Returns:
        Path a la carpeta solicitada
    """
    path = get_project_root() / "outputs" / subfolder
    path.mkdir(parents=True, exist_ok=True)
    return path
