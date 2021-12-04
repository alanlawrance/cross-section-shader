using UnityEngine;
using System.Collections;
[ExecuteInEditMode]
public class TwoPlanesCuttingController : MonoBehaviour {

    public GameObject plane1;
    public GameObject plane2;
    public Renderer rend;

    private Vector3 normal1;
    private Vector3 position1;
    private Vector3 normal2;
    private Vector3 position2;

    private MaterialPropertyBlock m_MaterialPropertyBlock;

    private void Awake()
    {
        m_MaterialPropertyBlock = new MaterialPropertyBlock();
    }

    private void Start()
    {
        UpdateShaderProperties();
    }

#if UNITY_EDITOR
    private void Update()
    {
        UpdateShaderProperties();
    }
#endif

    public void UpdateShaderProperties()
    {
        if (plane1) {
            normal1 = plane1.transform.TransformVector(new Vector3(0, 0, -1));
            position1 = plane1.transform.position;
        } else {
            normal1 = -Vector3.forward;
            position1 = new Vector3(0f, 0f, -1000f);
        }

        if (plane2) {
            normal2 = plane2.transform.TransformVector(new Vector3(0, 0, -1));
            position2 = plane2.transform.position;
        } else {
            normal2 = -Vector3.forward;
            position2 = new Vector3(0f, 0f, 1000f);
        }

        m_MaterialPropertyBlock.SetVector("Vector3_Plane1_Normal", normal1);
        m_MaterialPropertyBlock.SetVector("Vector3_Plane1_Position", position1);
        m_MaterialPropertyBlock.SetVector("Vector3_Plane2_Normal", normal2);
        m_MaterialPropertyBlock.SetVector("Vector3_Plane2_Position", position2);

        rend.SetPropertyBlock(m_MaterialPropertyBlock);
    }
}
