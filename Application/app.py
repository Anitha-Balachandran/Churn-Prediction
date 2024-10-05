from flask import Flask, render_template, request, jsonify
import joblib  # Still using joblib for loading the model
import numpy as np
from sklearn.preprocessing import LabelEncoder

app = Flask(__name__)

# Load the trained model using joblib
model = joblib.load("random_forest_model.pkl")  # Adjusted to .pkl

# Label encoders for categorical features
le_gender = LabelEncoder().fit(["Female", "Male"])
le_partner = LabelEncoder().fit(["Yes", "No"])
le_dependents = LabelEncoder().fit(["No", "Yes"])
le_phone_service = LabelEncoder().fit(["No", "Yes"])
le_multiple_lines = LabelEncoder().fit(["No phone service", "No", "Yes"])
le_internet_service = LabelEncoder().fit(["DSL", "Fiber optic", "No"])
le_online_security = LabelEncoder().fit(["No", "Yes", "No internet service"])
le_online_backup = LabelEncoder().fit(["Yes", "No", "No internet service"])
le_device_protection = LabelEncoder().fit(["No", "Yes", "No internet service"])
le_tech_support = LabelEncoder().fit(["No", "Yes", "No internet service"])
le_streaming_tv = LabelEncoder().fit(["No", "Yes", "No internet service"])
le_streaming_movies = LabelEncoder().fit(["No", "Yes", "No internet service"])
le_contract = LabelEncoder().fit(["Month-to-month", "One year", "Two year"])
le_paperless_billing = LabelEncoder().fit(["Yes", "No"])
le_payment_method = LabelEncoder().fit(
    [
        "Electronic check",
        "Mailed check",
        "Bank transfer (automatic)",
        "Credit card (automatic)",
    ]
)


@app.route("/")
def index():
    return render_template("index.html")


@app.route("/predict", methods=["POST"])
def predict():
    # Retrieve the form data
    data = request.form

    # Encode categorical features
    gender = le_gender.transform([data["gender"]])[0]
    senior_citizen = int(data["senior_citizen"])
    partner = le_partner.transform([data["partner"]])[0]
    dependents = le_dependents.transform([data["dependents"]])[0]
    tenure = int(data["tenure"])
    phone_service = le_phone_service.transform([data["phone_service"]])[0]
    multiple_lines = le_multiple_lines.transform([data["multiple_lines"]])[0]
    internet_service = le_internet_service.transform([data["internet_service"]])[0]
    online_security = le_online_security.transform([data["online_security"]])[0]
    online_backup = le_online_backup.transform([data["online_backup"]])[0]
    device_protection = le_device_protection.transform([data["device_protection"]])[0]
    tech_support = le_tech_support.transform([data["tech_support"]])[0]
    streaming_tv = le_streaming_tv.transform([data["streaming_tv"]])[0]
    streaming_movies = le_streaming_movies.transform([data["streaming_movies"]])[0]
    contract = le_contract.transform([data["contract"]])[0]
    paperless_billing = le_paperless_billing.transform([data["paperless_billing"]])[0]
    payment_method = le_payment_method.transform([data["payment_method"]])[0]
    monthly_charges = float(data["monthly_charges"])
    total_charges = float(data["total_charges"])

    # Prepare the input for the model
    input_data = np.array(
        [
            [
                gender,
                senior_citizen,
                partner,
                dependents,
                tenure,
                phone_service,
                multiple_lines,
                internet_service,
                online_security,
                online_backup,
                device_protection,
                tech_support,
                streaming_tv,
                streaming_movies,
                contract,
                paperless_billing,
                payment_method,
                monthly_charges,
                total_charges,
            ]
        ]
    )

    # Make prediction
    prediction = model.predict(input_data)

    # Decode prediction
    result = (
        "Customer is likely to churn"
        if prediction[0] == 1
        else "Customer is not likely to churn"
    )

    return jsonify(result=result)


if __name__ == "__main__":
    app.run(debug=True)
