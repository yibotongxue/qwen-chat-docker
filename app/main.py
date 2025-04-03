from flask import Flask, request, jsonify
from modelscope import AutoModelForCausalLM, AutoTokenizer
import torch

app = Flask(__name__)

# 加载模型和分词器（单次加载，避免重复初始化）[[3]][[7]]
model_path = "Qwen/Qwen2.5-1.5B-Instruct-GPTQ-Int4"
device = "cuda" if torch.cuda.is_available() else "cpu"

model = AutoModelForCausalLM.from_pretrained(
    model_path,
    device_map="auto",
    trust_remote_code=True,  # 必须参数，支持自定义模型代码[[3]]
    attn_implementation="flash_attention_2",
).eval()

tokenizer = AutoTokenizer.from_pretrained(model_path, trust_remote_code=True)

@app.route('/chat', methods=['POST'])
def chat_api():
    data = request.json
    prompt = data.get('prompt', '')

    if not prompt:
        return jsonify({'error': 'Missing prompt'}), 400

    try:
        inputs = tokenizer(prompt, return_tensors="pt").to(device)
        input_length = inputs.input_ids.shape[1]
        outputs = model.generate(**inputs, max_new_tokens=512)
        response = tokenizer.decode(
            outputs[0][input_length:],
            skip_special_tokens=True,
            clean_up_tokenization_spaces=True
        )

        # 关键修复：禁用ASCII转义
        return jsonify({'response': response}), 200, {'ensure_ascii': False}

    except Exception as e:
        return jsonify({'error': str(e)}), 500

if __name__ == "__main__":
    # 启动API服务（默认端口7860）
    app.run(host='0.0.0.0', port=7860)
