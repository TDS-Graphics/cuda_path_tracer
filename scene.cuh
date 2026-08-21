#pragma once

#include "camera.cuh"
#include "common.cuh"

struct Mesh {
  glm::vec3 *vertices;
  glm::ivec2 *uv;
  glm::int32 *indices;
};

class CObject {
public:
  CObject() {
    uid = GenUUID();
    position = {};
    rotation = {};
    scale = {};
  }

  std::string uid;

  glm::vec3 position;
  glm::vec3 rotation;
  glm::vec3 scale;

private:
};

class CScene {
public:
  void Add(CObject &obj) { objects.insert({obj.uid, obj}); }
  void Remove(std::string &uuid) { objects.erase(uuid); }
  void Clean() { objects.clear(); }

  void Rendering(glm::ivec2 _resolution, Mesh *meshs, glm::int32 *mesh_count) {
    camera.aspect_ratio = static_cast<float>(_resolution.x) / static_cast<float>(_resolution.y);
  }

  CCamera camera;

private:
  std::map<std::string, CObject> objects;
};
