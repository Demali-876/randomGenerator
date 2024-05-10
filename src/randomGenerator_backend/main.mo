import Blob "mo:base/Blob";
import Nat "mo:base/Nat";
import Nat8 "mo:base/Nat8";
import Iter "mo:base/Iter";

actor RandomGenerator {
    let SubnetManager : actor {
        raw_rand() : async Blob;
    } = actor "aaaaa-aa"; // Management canister

    // Utility function to convert Blob to Nat
    private func convertBlobToNat(blob: Blob) : Nat {
        let bytes = Blob.toArray(blob);
        var num : Nat = 0;
        // Use .size to get the number of elements
        let size = bytes.size();
        // Create an iterator for byte array indices
        let bytesIter = Iter.range(0, size - 1);
        // Iterate through each index in the byte array
        for (index in bytesIter) {
            let byte = bytes[index];
            num := num * 256 + Nat8.toNat(byte); // Convert each byte to Nat 
        };
        return num;
    };
    // Get a random number within a specific range [min, max]
    public func getRandomNumberInRange(min: Nat, max: Nat) : async Nat {
        assert(min < max);
        let entropy = await SubnetManager.raw_rand();
        let num = convertBlobToNat(entropy);
        return min + (num % (max - min + 1));
    };

    // Get a random boolean based on numeric conditions (1 for true, 2 for false)
    public func getRandomBoolean() : async Bool {
        let num = await getRandomNumberInRange(1, 2);
        return num == 1;
    };

    // Get a random odd number within a range
    public func getRandomOddNumber(max: Nat) : async Nat {
        assert(max > 0);
        var num = await getRandomNumberInRange(0, max);
        while (num % 2 == 0) { // Ensure the number is odd
            num := await getRandomNumberInRange(0, max);
        };
        return num;
    };

    // Get a random even number within a range
    public func getRandomEvenNumber(max: Nat) : async Nat {
        assert(max > 0);
        var num = await getRandomNumberInRange(0, max);
        while (num % 2 != 0) { // Ensure the number is even
            num := await getRandomNumberInRange(0, max);
        };
        return num;
    };

    // Check if a number is prime
    private func isPrime(n: Nat) : Bool {
        if (n < 2) { return false; };
        if (n == 2 or n == 3) { return true; };
        if (n % 2 == 0 or n % 3 == 0) { return false; };
        var i : Nat = 5;
        while (i * i <= n) {
            if (n % i == 0 or n % (i + 2) == 0) {
                return false;
            };
            i := i + 6;
        };
        return true;
    };

    // Get a random prime number within a range
    public func getRandomPrimeNumber(max: Nat) : async Nat {
        assert(max > 1);
        var num = await getRandomNumberInRange(2, max);
        while (not isPrime(num)) {
            num := await getRandomNumberInRange(2, max);
        };
        return num;
    };
}

